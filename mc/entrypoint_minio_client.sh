#!/bin/bash
# Script pour configurer le client MinIO

# Attendre que MinIO soit prêt
while ! curl -f http://minio:${MINIO_PORT}/minio/health/live; do
  echo "Waiting for MinIO to be ready..."
  sleep 5
done

# Ajouter l'alias et configurer le bucket
mc alias set myminio http://minio:${MINIO_PORT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}
mc mb myminio/mlflow
mc policy set public myminio/mlflow
