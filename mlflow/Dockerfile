# mlflow/Dockerfile
FROM ghcr.io/mlflow/mlflow:v2.17.2

RUN apt-get update && apt-get install -y curl iputils-ping \
    && pip install boto3 psycopg2-binary numpy pandas scikit-learn

COPY wait-for-it.sh /wait-for-it.sh
COPY entrypoint.sh /entrypoint_mlflow.sh
RUN chmod +x /wait-for-it.sh /entrypoint_mlflow.sh

ENTRYPOINT ["/entrypoint_mlflow.sh"]
