#!/bin/bash
set -e

# Attendre que PostgreSQL soit disponible
./wait-for-it.sh postgres:${POSTGRES_PORT} -- echo "PostgreSQL is up"

# Attendre que MinIO soit disponible
./wait-for-it.sh minio:${MINIO_PORT} -- echo "MinIO is up"

# Lancer MLflow Server
exec mlflow server \
    --backend-store-uri ${MLFLOW_BACKEND_STORE_URI} \
    --default-artifact-root ${MLFLOW_ARTIFACT_ROOT} \
    --host 0.0.0.0 \
    --port ${MLFLOW_PORT}
