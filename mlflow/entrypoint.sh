#!/bin/bash
set -e

# Exporter les variables nécessaires pour l'intégration avec MinIO
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export MLFLOW_S3_ENDPOINT_URL=${MLFLOW_S3_ENDPOINT_URL:-http://minio:9000}

# Attendre que les dépendances soient prêtes
/wait-for-it.sh ${POSTGRES_HOST}:${POSTGRES_PORT} -- echo "PostgreSQL is up"
/wait-for-it.sh ${MINIO_HOST}:${MINIO_PORT} -- echo "MinIO is up"

# Lancer MLflow Server
exec mlflow server \
    --backend-store-uri ${MLFLOW_BACKEND_STORE_URI} \
    --default-artifact-root ${MLFLOW_ARTIFACT_ROOT} \
    --host 0.0.0.0 \
    --port ${MLFLOW_PORT}
