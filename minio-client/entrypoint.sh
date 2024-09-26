#!/bin/bash
# Script for configuring the MinIO client

# Set the MINIO_PORT environment variable
export MINIO_PORT=9000
export MINIO_ROOT_USER=minio
export MINIO_ROOT_PASSWORD=minio123

# Wait for MinIO to be ready
while ! mc ls myminio > /dev/null 2>&1; do
    echo "Waiting for MinIO to be ready..."
    sleep 5
done

# Add the alias and configure the bucket
mc alias set myminio http://minio:${MINIO_PORT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}
mc mb myminio/mlflow
mc mb myminio/labestudio
mc policy set public myminio/mlflow
mc policy set public myminio/labestudio
