# Utilisation de l'image de base officielle Label Studio
FROM heartexlabs/label-studio:latest

# Passer à l'utilisateur root pour changer les permissions
USER root

# Copier le script d'entrée personnalisé dans le conteneur
COPY entrypoint.sh /entrypoint_label_studio.sh

# Rendre le script exécutable
RUN chmod +x /entrypoint_label_studio.sh

# Revenir à l'utilisateur par défaut de l'image (si nécessaire)
# USER 1001


ENTRYPOINT ["/entrypoint_label_studio.sh"]

# Exposer le port pour Label Studio
EXPOSE 8080
