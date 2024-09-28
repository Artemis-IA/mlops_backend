#!/bin/bash

# Wait for PostgreSQL to be ready
/wait-for-it.sh postgres:${POSTGRES_PORT} --timeout=60 --strict -- \
  mlflow server --backend-store-uri $MLFLOW_BACKEND_STORE_URI \
    --default-artifact-root $MLFLOW_ARTIFACT_ROOT \
    --host 0.0.0.0 --port $MLFLOW_PORT
