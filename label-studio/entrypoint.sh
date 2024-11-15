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

# label-studio init -b ${LABEL_STUDIO_PROJECT_NAME} -db postgresql --username ${LABEL_STUDIO_EMAIL} --password ${LABEL_STUDIO_PASSWORD} 

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

echo "=> Starting Label Studio"
 label-studio start -b -db postgresql --init "${LABEL_STUDIO_PROJECT_NAME}" --host 0.0.0.0 --port "${LABEL_STUDIO_PORT}" \
   --username "${LABEL_STUDIO_EMAIL}" --password "${LABEL_STUDIO_PASSWORD}" --user-token ${LABEL_STUDIO_API_KEY} \
  --database "${DATABASE_URL}" --log-level WARNING --no-browser --config /label-studio/config/storage.json
# Attendre que Label Studio soit prêt
echo "=> Attente de la disponibilité de Label Studio..."
until curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/projects" \
           -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" > /dev/null; do
  sleep 5
  echo "En attente de Label Studio..."
done
echo "Label# Vérification ou création du projet
echo "=> Vérification ou création du projet '${LABEL_STUDIO_PROJECT_NAME}'..."
PROJECT_ID=$(curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/projects" \
             -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" | jq -r ".[] | select(.title==\"${LABEL_STUDIO_PROJECT_NAME}\") | .id")

if [ -z "$PROJECT_ID" ]; then
  echo "=> Création du projet '${LABEL_STUDIO_PROJECT_NAME}'..."
  PROJECT_ID=$(curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/projects" \
    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"title\": \"${LABEL_STUDIO_PROJECT_NAME}\"}" | jq -r ".id")
  echo "Projet créé avec ID : $PROJECT_ID"
else
  echo "Le projet '${LABEL_STUDIO_PROJECT_NAME}' existe déjà avec ID : $PROJECT_ID"
fi

# Configuration du stockage MinIO
echo "=> Configuration du stockage MinIO..."
STORAGE_EXISTS=$(curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/storages/s3" \
                 -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" | jq -r ".[] | select(.title==\"${LABEL_STUDIO_BUCKET_NAME}\" and .project==$PROJECT_ID) | .id")

if [ -z "$STORAGE_EXISTS" ]; then
  echo "=> Ajout du stockage MinIO..."
  curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/storages/s3" \
    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
      \"title\": \"${LABEL_STUDIO_BUCKET_NAME}\",
      \"bucket\": \"${LABEL_STUDIO_BUCKET_NAME}\",
      \"prefix\": \"\",
      \"use_blob_urls\": true,
      \"presign\": true,
      \"endpoint_url\": \"${LABEL_STUDIO_BUCKET_ENDPOINT_URL}\",
      \"access_key\": \"${LABEL_STUDIO_BUCKET_ACCESS_KEY}\",
      \"secret_key\": \"${LABEL_STUDIO_BUCKET_SECRET_KEY}\",
      \"region\": \"us-east-1\",
      \"project\": $PROJECT_ID
    }"
  echo "Stockage MinIO configuré pour le projet '${LABEL_STUDIO_PROJECT_NAME}'"
else
  echo "Le stockage MinIO est déjà configuré pour le projet '${LABEL_STUDIO_PROJECT_NAME}'"
fi

# Ajout du backend GLiNER
echo "=> Ajout du backend GLiNER..."
ML_BACKEND_EXISTS=$(curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/ml" \
                    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" | jq -r ".[] | select(.title==\"GLiNER\" and .project==$PROJECT_ID) | .id")

if [ -z "$ML_BACKEND_EXISTS" ]; then
  echo "=> Connexion du modèle GLiNER..."
  curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/ml" \
    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
      \"url\": \"http://gliner:5001\",
      \"title\": \"GLiNER\",
      \"description\": \"Modèle GLiNER pour NER\",
      \"project\": $PROJECT_ID
    }"
  echo "Modèle GLiNER connecté au projet '${LABEL_STUDIO_PROJECT_NAME}'"
else
  echo "Le backend GLiNER est déjà configuré pour le projet '${LABEL_STUDIO_PROJECT_NAME}'"
fi

# Maintenir le processus en cours
tail -f /dev/null

# gunicorn -w 4 -b 0.0.0.0:8081 core.wsgi:application