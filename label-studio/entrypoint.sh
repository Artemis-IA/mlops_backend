#!/bin/bash
set -e

# Check for missing essential environment variables
if [[ -z "${LABEL_STUDIO_EMAIL}" || -z "${LABEL_STUDIO_PASSWORD}" || -z "${POSTGRE_HOST}" || -z "${POSTGRE_PORT}" || -z "${POSTGRE_DB}" ]]; then
  echo "ERROR: Missing required environment variables. Exiting."
  exit 1
fi

# Set HOST environment variable to avoid warning (ensure it starts with http:// or https://)
if [[ -z "${LABEL_STUDIO_HOST}" ]]; then
  export LABEL_STUDIO_HOST="http://0.0.0.0"
fi

# Wait for PostgreSQL to be available
echo "=> Waiting for PostgreSQL to be available..."
until pg_isready -h ${POSTGRE_HOST} -p ${POSTGRE_PORT} -U ${POSTGRE_USER}; do
  sleep 5
  echo "Waiting for PostgreSQL..."
done
echo "PostgreSQL is available."

# Set the database URL for PostgreSQL (as Label Studio expects a single environment variable)
export DATABASE_URL="postgresql://${POSTGRE_USER}:${POSTGRE_PASSWORD}@${POSTGRE_HOST}:${POSTGRE_PORT}/${POSTGRE_DB}"

# # Check if the project exists before initializing
# if ! label-studio list | grep -q "${LABEL_STUDIO_PROJECT_NAME}"; then
#   echo "=> Initializing Label Studio project '${LABEL_STUDIO_PROJECT_NAME}'..."
#   label-studio init ${LABEL_STUDIO_PROJECT_NAME}
# else
#   echo "=> Label Studio project '${LABEL_STUDIO_PROJECT_NAME}' already exists."
# fi

label-studio init ${LABEL_STUDIO_PROJECT_NAME} -db postgresql --username ${LABEL_STUDIO_EMAIL} --password ${LABEL_STUDIO_PASSWORD} 

# Wait for MinIO to be available
echo "=> Waiting for MinIO to be available..."
until curl -s "${LABEL_STUDIO_BUCKET_ENDPOINT_URL}" > /dev/null; do
  echo "Waiting for MinIO..."
  sleep 5
done
echo "MinIO is available."

# Configure MinIO in Label Studio
echo "=> Configuring MinIO storage in Label Studio"
mkdir -p /label-studio/config
cat <<EOF > /label-studio/config/storage.json
{
  "storage_type": "s3",
  "title": "${LABEL_STUDIO_BUCKET_NAME}",
  "bucket": "${LABEL_STUDIO_BUCKET_NAME}",
  "prefix": "/",
  "use_blob_urls": true,
  "presign": true,
  "endpoint_url": "${LABEL_STUDIO_BUCKET_ENDPOINT_URL}",
  "access_key": "${LABEL_STUDIO_BUCKET_ACCESS_KEY}",
  "secret_key": "${LABEL_STUDIO_BUCKET_SECRET_KEY}",
  "region": "us-east-1"
}
EOF

# Start Label Studio
echo "=> Starting Label Studio"
exec label-studio start -db postgresql --host 0.0.0.0 --port "${LABEL_STUDIO_PORT}" --no-browser "${LABEL_STUDIO_PROJECT_NAME}" \
  --no-browser --username "${LABEL_STUDIO_EMAIL}" --password "${LABEL_STUDIO_PASSWORD}" \
  --database "${DATABASE_URL}"

# gunicorn -w 4 -b 0.0.0.0:8081 core.wsgi:application