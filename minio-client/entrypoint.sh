#!/bin/bash
set -e

# Set environment variables for MinIO
export MINIO_PORT=${MINIO_PORT}
export MINIO_ROOT_USER=${MINIO_ROOT_USER}
export MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}

# Set proxy environment variables if available
export HTTP_PROXY=${HTTP_PROXY}
export HTTPS_PROXY=${HTTPS_PROXY}

# Configure the alias and create buckets
mc alias set myminio http://minio:${MINIO_PORT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}

# Create buckets if they don't exist
mc mb myminio/data || echo "Bucket 'data' already exists."
mc mb myminio/mlflow || echo "Bucket 'mlflow' already exists."
mc mb myminio/labelstudio || echo "Bucket 'labelstudio' already exists."

# Set bucket policies to public
mc policy set public myminio/data
mc policy set public myminio/mlflow
mc policy set public myminio/labelstudio

# Apply CORS policy to MinIO
echo "=> Applying CORS policy to MinIO"
if [ -f /label-studio/data/cors.json ]; then
  mc admin policy create myminio cors /label-studio/data/cors.json || echo "CORS policy already applied."
else
  echo "CORS policy file not found at /label-studio/data/cors.json"
fi

# Keep container alive
tail -f /dev/null
