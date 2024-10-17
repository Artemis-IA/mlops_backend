#!/bin/bash
set -e

# Display environment variables for debugging
echo "=> Starting Label Studio with the following environment:"
echo "   LABEL_STUDIO_EMAIL=${LABEL_STUDIO_EMAIL}"
echo "   LABEL_STUDIO_PASSWORD=${LABEL_STUDIO_PASSWORD}"
echo "   LABEL_STUDIO_BUCKET_NAME=${LABEL_STUDIO_BUCKET_NAME}"
echo "   LABEL_STUDIO_BUCKET_ENDPOINT_URL=${LABEL_STUDIO_BUCKET_ENDPOINT_URL}"
echo "   POSTGRE_HOST=${POSTGRE_HOST}"
echo "   POSTGRE_PORT=${POSTGRE_PORT}"

# Wait for PostgreSQL to be available
echo "=> Waiting for PostgreSQL to be available..."
until pg_isready -h ${POSTGRE_HOST} -p ${POSTGRE_PORT} -U ${POSTGRE_USER}; do
  sleep 5
  echo "Waiting for PostgreSQL..."
done
echo "PostgreSQL is available."

# Set the database URL for PostgreSQL (as Label Studio expects a single environment variable)
export DATABASE_URL="postgresql://${POSTGRE_USER}:${POSTGRE_PASSWORD}@${POSTGRE_HOST}:${POSTGRE_PORT}/${POSTGRE_DB}"

# Initialize and start Label Studio
echo "=> Initializing and starting Label Studio with PostgreSQL"
label-studio init ${LABEL_STUDIO_PROJECT_NAME}
label-studio start -init -db postgresql --username ${LABEL_STUDIO_EMAIL} --password ${LABEL_STUDIO_PASSWORD} \
  --db postgresql --db-host ${POSTGRE_HOST} --db-port ${POSTGRE_PORT} --db-name ${POSTGRE_DB} \
  --db-user ${POSTGRE_USER} --db-password ${POSTGRE_PASSWORD}

# Wait for MinIO to be available
echo "=> Waiting for MinIO to be available..."
until curl -s "${LABEL_STUDIO_BUCKET_ENDPOINT_URL}" > /dev/null; do
  echo "Waiting for MinIO..."
  sleep 5
done
echo "MinIO is available."

# Configure MinIO in Label Studio
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

# Start Label Studio
echo "=> Starting Label Studio"
exec label-studio start --host 0.0.0.0 --port "${LABEL_STUDIO_PORT}" --no-browser
