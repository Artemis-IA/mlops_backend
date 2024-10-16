#!/bin/bash
set -e

# Vérifier si on utilise le proxy d'entreprise
if [ "$USE_ET_PROXY" = "false" ]; then
  echo "Proxy désactivé car USE_ET_PROXY est false."
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset NO_PROXY
else
  echo "Utilisation du proxy d'entreprise."
  export HTTP_PROXY=${HTTP_PROXY}
  export HTTPS_PROXY=${HTTPS_PROXY}
  export NO_PROXY=${NO_PROXY}
fi

TOKEN_FILE="/tmp/haproxy_token.txt"

# Fonction pour attendre qu'un service soit disponible
wait_for_service() {
  local host=$1
  local port=$2
  echo "Attente de $host:$port..."
  while ! nc -z $host $port; do
    echo "Le service $host sur le port $port n'est pas encore disponible, nouvelle tentative dans 1s..."
    sleep 1
  done
  echo "$host:$port est maintenant disponible."
}

# Étape d'attente pour les services
echo "Vérification de la disponibilité des services..."

wait_for_service "minio" "${MINIO_PORT}"
wait_for_service "label-studio" "${LABEL_STUDIO_PORT}"
wait_for_service "mlflow" "${MLFLOW_PORT}"

echo "Tous les services sont disponibles."

# Vérifier si le token a déjà été récupéré
if [ -f "$TOKEN_FILE" ]; then
  echo "Le token a déjà été récupéré : $(cat $TOKEN_FILE)"
else
  echo "Tentative de récupération du token de HAProxy via l'API Docker..."

  # Utiliser curl pour récupérer l'environnement du conteneur haproxydev via l'API Docker
  PROXY_TOKEN=$(curl --unix-socket /var/run/docker.sock http://haproxydev/containers/haproxydev/json | jq -r '.Config.Env[]' | grep 'PXYDEV_TOKEN' | cut -d '=' -f2)

  # Vérifier si la commande curl a réussi
  if [ $? -ne 0 ]; then
    echo "Erreur : impossible de récupérer le token via curl."
    exit 1
  fi

  # Ajouter un message pour afficher le token récupéré
  echo "Token récupéré avec succès : $PROXY_TOKEN"
  echo "$PROXY_TOKEN" > "$TOKEN_FILE"
fi

# Ajouter le token d'authentification dans la configuration Nginx
export PROXY_AUTH=$(cat $TOKEN_FILE)
echo "Le token d'authentification a été ajouté à la configuration Nginx."

# Remplacer les variables d'environnement dans nginx.conf.template pour générer nginx.conf
echo "Génération du fichier nginx.conf à partir du template..."
envsubst '${MINIO_PORT} ${MINIO_CONSOLE_PORT} ${LABEL_STUDIO_PORT} ${MLFLOW_PORT} ${PROXY_AUTH}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Vérifier que le fichier de configuration existe
if [ ! -f /etc/nginx/nginx.conf ]; then
    echo "Erreur : le fichier nginx.conf est manquant !"
    exit 1
fi
echo "Le fichier nginx.conf a été généré avec succès."

# Afficher le contenu de nginx.conf pour vérification
echo "Contenu de nginx.conf :"
cat /etc/nginx/nginx.conf

# Démarrer Nginx en mode non-détaché pour que le conteneur reste actif
echo "Démarrage de Nginx..."
nginx -g 'daemon off;'
