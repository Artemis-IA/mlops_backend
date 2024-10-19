# nginx/Dockerfile

FROM nginx:latest

# Installer envsubst (via gettext-base)
RUN apt-get update \
    && apt-get install -y jq gettext-base netcat-openbsd \
    && rm -rf /var/lib/apt/lists/* \
    && groupmod -g 998 www-data \
    && usermod -aG 998 www-data
    
# # Copier la configuration Nginx template
# COPY nginx.conf /etc/nginx/nginx.conf.template

# # Copier le script d'entrypoint
# COPY entrypoint.sh /entrypoint.sh

# # Donner les permissions d'exécution au script d'entrypoint
# RUN chmod +x /entrypoint.sh

# # Définir le script d'entrypoint
# ENTRYPOINT ["/entrypoint.sh"]

# Exposer les ports 80 et 443
EXPOSE 80 443
