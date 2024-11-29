#!/bin/bash
set -e

# Set environment variables for MinIO
export MINIO_PORT=${MINIO_PORT}
export MINIO_ROOT_USER=${MINIO_ROOT_USER}
export MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}

# Set proxy environment variables if available
export HTTP_PROXY=${HTTP_PROXY}
export HTTPS_PROXY=${HTTPS_PROXY}

echo "Setting MinIO alias..."
mc alias set myminio http://minio:${MINIO_PORT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD} || {
  echo "Failed to set alias for MinIO"
  exit 1
}

echo "Creating buckets..."
mc mb myminio/data || echo "Bucket 'data' already exists."
mc mb myminio/mlflow || echo "Bucket 'mlflow' already exists."
mc mb myminio/labelstudio || echo "Bucket 'labelstudio' already exists."

echo "Setting public policies for buckets..."
mc anonymous set public myminio/data || echo "Failed to set public policy for 'data'"
mc anonymous set public myminio/mlflow || echo "Failed to set public policy for 'mlflow'"
mc anonymous set public myminio/labelstudio || echo "Failed to set public policy for 'labelstudio'"


echo "=> Applying CORS policy to MinIO"
if [ -f /label-studio/cors.json ]; then
  mc admin policy create myminio cors /label-studio/cors.json || echo "CORS policy already applied."
else
  echo "CORS policy file not found at /label-studio/cors.json"
fi

# Keep container alive
tail -f /dev/null