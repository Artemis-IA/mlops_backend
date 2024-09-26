#!/bin/bash
# Script pour démarrer MLflow avec des variables d'environnement préconfigurées

mlflow server \
    --host 0.0.0.0 \
    --backend-store-uri $MLFLOW_BACKEND_STORE_URI \
    --default-artifact-root $MLFLOW_ARTIFACT_ROOT
# 