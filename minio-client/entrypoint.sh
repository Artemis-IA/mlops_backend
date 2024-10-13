#!/bin/bash
set -e

# Set the MINIO_PORT environment variable
export MINIO_PORT=${MINIO_PORT}
export MINIO_ROOT_USER=${MINIO_ROOT_USER}
export MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}

# Configurer l'alias et créer les buckets
mc alias set myminio http://minio:${MINIO_PORT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}
mc mb myminio/data || echo "Bucket 'data' already exists."
mc mb myminio/mlflow || echo "Bucket 'mlflow' already exists."
mc mb myminio/labelstudio || echo "Bucket 'labelstudio' already exists."

# Définir la politique de bucket comme publique
mc policy set public myminio/data
mc policy set public myminio/mlflow
mc policy set public myminio/labelstudio

# Appliquer les règles CORS pour MinIO
echo "=> Applying CORS policy to MinIO"
mc alias set myminio http://minio:${MINIO_PORT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}
if [ -f /label-studio/data/cors.json ]; then
  mc admin policy create myminio cors /label-studio/data/cors.json || echo "CORS policy already applied."
else
  echo "CORS policy file not found at /label-studio/data/cors.json"
fi

# Garder le conteneur en vie
tail -f /dev/null
