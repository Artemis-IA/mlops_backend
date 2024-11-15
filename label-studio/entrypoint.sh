#!/bin/bash
set -e

# Function to wait for service availability
wait_for_service() {
    local service=$1
    local check_command=$2
    echo "=> Waiting for $service..."
    until eval $check_command; do
        sleep 5
        echo "$service is not ready yet..."
    done
    echo "$service is available."
}

# Verify S3 credentials before starting
verify_s3_credentials() {
    echo "=> Verifying S3 credentials..."
    if ! aws --endpoint-url="${LABEL_STUDIO_BUCKET_ENDPOINT_URL}" \
            s3 ls "s3://${LABEL_STUDIO_BUCKET_NAME}" \
            --access-key "${LABEL_STUDIO_BUCKET_ACCESS_KEY}" \
            --secret-key "${LABEL_STUDIO_BUCKET_SECRET_KEY}" \
            --region us-east-1 >/dev/null 2>&1; then
        echo "ERROR: Cannot connect to S3. Please verify your credentials and bucket configuration."
        return 1
    fi
    echo "S3 credentials verified successfully."
}

# Verify required environment variables
required_vars=(
    "LABEL_STUDIO_EMAIL"
    "LABEL_STUDIO_PASSWORD"
    "POSTGRE_HOST"
    "POSTGRE_PORT"
    "POSTGRE_DB"
    "LABEL_STUDIO_BUCKET_NAME"
    "LABEL_STUDIO_BUCKET_ENDPOINT_URL"
    "LABEL_STUDIO_BUCKET_ACCESS_KEY"
    "LABEL_STUDIO_BUCKET_SECRET_KEY"
    "MLBACKEND_PORT"
)

for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        echo "ERROR: Required environment variable $var is not set"
        exit 1
    fi
done

# Set default host if not defined
export LABEL_STUDIO_HOST=${LABEL_STUDIO_HOST:-"http://0.0.0.0"}

# Wait for PostgreSQL
wait_for_service "PostgreSQL" "pg_isready -h ${POSTGRE_HOST} -p ${POSTGRE_PORT} -U ${POSTGRE_USER}"

# Configure database URL
export DATABASE_URL="postgresql://${POSTGRE_USER}:${POSTGRE_PASSWORD}@${POSTGRE_HOST}:${POSTGRE_PORT}/${POSTGRE_DB}"

# Wait for MinIO
wait_for_service "MinIO" "curl -s ${LABEL_STUDIO_BUCKET_ENDPOINT_URL} > /dev/null"

# Start Label Studio
echo "=> Starting Label Studio..."
label-studio start -b -db postgresql \
    --init "${LABEL_STUDIO_PROJECT_NAME}" \
    --host 0.0.0.0 \
    --port "${LABEL_STUDIO_PORT}" \
    --username "${LABEL_STUDIO_EMAIL}" \
    --password "${LABEL_STUDIO_PASSWORD}" \
    --user-token "${LABEL_STUDIO_API_KEY}" \
    --database "${DATABASE_URL}" \
    --log-level WARNING &

# Wait for Label Studio API
wait_for_service "Label Studio" "curl -s -f http://localhost:${LABEL_STUDIO_PORT}/health || false"

# Function to make API calls with proper error handling
api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    local response
    
    response=$(curl -s -X "${method}" \
        "http://localhost:${LABEL_STUDIO_PORT}${endpoint}" \
        -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" \
        -H "Content-Type: application/json" \
        ${data:+-d "$data"})
    
    if [[ $? -ne 0 ]]; then
        echo "API call failed: ${endpoint}"
        return 1
    fi
    echo "${response}"
}

# Get or create project
echo "=> Checking if project '${LABEL_STUDIO_PROJECT_NAME}' exists..."
projects_response=$(api_call "GET" "/api/projects")
project_id=$(echo "${projects_response}" | jq -r ".results[] | select(.title==\"${LABEL_STUDIO_PROJECT_NAME}\") | .id")

if [[ -z "${project_id}" ]]; then
    echo "=> Creating project '${LABEL_STUDIO_PROJECT_NAME}'..."
    create_response=$(api_call "POST" "/api/projects" "{
        \"title\": \"${LABEL_STUDIO_PROJECT_NAME}\",
        \"description\": \"Automatically initialized project\",
        \"label_config\": \"<View><Text name='text' value='\$text'/></View>\"
    }")
    project_id=$(echo "${create_response}" | jq -r ".id")
fi

echo "Project ID: ${project_id}"

# Configure S3 source storage
echo "=> Configuring S3 source storage..."
s3_config="{
    \"title\": \"${LABEL_STUDIO_BUCKET_NAME}\",
    \"bucket\": \"${LABEL_STUDIO_BUCKET_NAME}\",
    \"prefix\": \"${LABEL_STUDIO_BUCKET_PREFIX}\",
    \"use_blob_urls\": true,
    \"presign\": true,
    \"endpoint_url\": \"${LABEL_STUDIO_BUCKET_ENDPOINT_URL}\",
    \"access_key\": \"${LABEL_STUDIO_BUCKET_ACCESS_KEY}\",
    \"secret_key\": \"${LABEL_STUDIO_BUCKET_SECRET_KEY}\",
    \"region\": \"us-east-1\",
    \"project\": ${project_id}
}"

source_storage_response=$(api_call "POST" "/api/storages/s3" "${s3_config}")
source_storage_id=$(echo "${source_storage_response}" | jq -r ".id")

if [[ -n "${source_storage_id}" ]]; then
    echo "=> Syncing tasks from S3..."
    api_call "POST" "/api/storages/s3/${source_storage_id}/sync"
fi

# Configure ML backend
echo "=> Adding GLiNER backend..."
ml_config="{
    \"url\": \"http://gliner:${MLBACKEND_PORT}\",
    \"title\": \"GLiNER\",
    \"description\": \"GLiNER model for NER\",
    \"project\": ${project_id}
}"

api_call "POST" "/api/ml" "${ml_config}"

# Keep container running
tail -f /dev/null