#!/bin/bash
set -e

# Afficher les variables d'environnement pour le débogage
echo "=> Starting Label Studio with the following environment:"
echo "   LABEL_STUDIO_USERNAME=${LABEL_STUDIO_USERNAME}"
echo "   LABEL_STUDIO_PASSWORD=${LABEL_STUDIO_PASSWORD}"
echo "   LABEL_STUDIO_BUCKET_NAME=${LABEL_STUDIO_BUCKET_NAME}"
echo "   LABEL_STUDIO_BUCKET_ENDPOINT_URL=${LABEL_STUDIO_BUCKET_ENDPOINT_URL}"
echo "   POSTGRE_HOST=${POSTGRE_HOST}"
echo "   POSTGRE_PORT=${POSTGRE_PORT}"

# Attendre que PostgreSQL soit disponible
echo "=> Waiting for PostgreSQL to be available..."
until pg_isready -h ${POSTGRE_HOST} -p ${POSTGRE_PORT} -U ${POSTGRE_USER}; do
  sleep 5
  echo "Waiting for PostgreSQL..."
done
echo "PostgreSQL is available."

# Initialiser et démarrer le projet Label Studio avec PostgreSQL
echo "=> Initializing Label Studio with PostgreSQL"
label-studio start ${LABEL_STUDIO_PROJECT_NAME} --init -b --username ${LABEL_STUDIO_USERNAME} --password ${LABEL_STUDIO_PASSWORD} -db postgresql || true

# Attendre que MinIO soit disponible
echo "=> Waiting for MinIO to be available..."
until curl -s "${LABEL_STUDIO_BUCKET_ENDPOINT_URL}" > /dev/null; do
  echo "Waiting for MinIO..."
  sleep 5
done
echo "MinIO is available."

# Configurer manuellement MinIO dans les fichiers de configuration
echo "=> Configuring MinIO storage in Label Studio"

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

# Lancer Label Studio avec la configuration MinIO
echo "=> Starting Label Studio"
exec label-studio start --host 0.0.0.0 --port "${LABEL_STUDIO_PORT}" --no-browser
