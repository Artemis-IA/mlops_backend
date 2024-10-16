# minio_client/Dockerfile
FROM minio/mc:latest

# Copier le script d'entrypoint
COPY entrypoint.sh /entrypoint_minio_client.sh

# Donner les permissions d'exécution au script d'entrypoint
RUN chmod +x /entrypoint_minio_client.sh

# Définir le script d'entrypoint
ENTRYPOINT ["/entrypoint_minio_client.sh"]
