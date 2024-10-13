#!/bin/bash
# nginx/entrypoint.sh

set -e

# Fonction pour attendre qu'un service soit disponible
wait_for_service() {
  local host=$1
  local port=$2
  echo "Attente de $host:$port..."
  while ! nc -z $host $port; do
    sleep 1
  done
  echo "$host:$port est disponible"
}

# Attendre que label-studio et mlflow soient disponibles
wait_for_service "label-studio" "${LABEL_STUDIO_PORT}"
wait_for_service "mlflow" "${MLFLOW_PORT}"

# Remplacer les variables d'environnement dans nginx.conf.template pour générer nginx.conf
envsubst '${LABEL_STUDIO_PORT} ${MLFLOW_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Vérifier que le fichier de configuration existe
if [ ! -f /etc/nginx/nginx.conf ]; then
    echo "Erreur : fichier nginx.conf manquant!"
    exit 1
fi

# Démarrer Nginx en mode non-détaché pour que le conteneur reste actif
nginx -g 'daemon off;'
