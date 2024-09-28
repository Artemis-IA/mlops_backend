# minio_client/Dockerfile
FROM minio/mc

COPY entrypoint.sh /entrypoint_minio_client.sh

RUN chmod +x /entrypoint_minio_client.sh

ENTRYPOINT ["/entrypoint_minio_client.sh"]