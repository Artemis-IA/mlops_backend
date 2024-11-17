#!/bin/bash
set -e

# Vérification des variables d'environnement essentielles
if [[ -z "${LABEL_STUDIO_EMAIL}" || -z "${LABEL_STUDIO_PASSWORD}" || -z "${POSTGRE_HOST}" || -z "${POSTGRE_PORT}" || -z "${POSTGRE_DB}" ]]; then
  echo "ERREUR : Variables d'environnement manquantes. Arrêt du script."
  exit 1
fi

# Définir LABEL_STUDIO_HOST par défaut si non défini
if [[ -z "${LABEL_STUDIO_HOST}" ]]; then
  export LABEL_STUDIO_HOST="http://0.0.0.0"
fi

# Attente de la disponibilité de PostgreSQL
echo "=> En attente de la disponibilité de PostgreSQL..."
until pg_isready -h ${POSTGRE_HOST} -p ${POSTGRE_PORT} -U ${POSTGRE_USER}; do
  sleep 5
  echo "PostgreSQL n'est pas encore prêt..."
done
echo "PostgreSQL est disponible."

# Configuration de l'URL de la base de données
export DATABASE_URL="postgresql://${POSTGRE_USER}:${POSTGRE_PASSWORD}@${POSTGRE_HOST}:${POSTGRE_PORT}/${POSTGRE_DB}"

# # Check if the project exists before initializing
# if ! label-studio list | grep -q "${LABEL_STUDIO_PROJECT_NAME}"; then
#   echo "=> Initializing Label Studio project '${LABEL_STUDIO_PROJECT_NAME}'..."
#   label-studio init ${LABEL_STUDIO_PROJECT_NAME}
# else
#   echo "=> Label Studio project '${LABEL_STUDIO_PROJECT_NAME}' already exists."
# fi

# label-studio init -b ${LABEL_STUDIO_PROJECT_NAME} -db postgresql --username ${LABEL_STUDIO_EMAIL} --password ${LABEL_STUDIO_PASSWORD} 

# Attente de la disponibilité de MinIO
echo "=> En attente de la disponibilité de MinIO..."
until curl -s "${LABEL_STUDIO_BUCKET_ENDPOINT_URL}" > /dev/null; do
  sleep 5
  echo "MinIO n'est pas encore prêt..."
done
echo "MinIO est disponible."

# # Configure MinIO in Label Studio
# echo "=> Configuring MinIO storage in Label Studio"
# mkdir -p /label-studio/config
# cat <<EOF > /label-studio/config/storage.json
# {
#   "storage_type": "s3",
#   "title": "${LABEL_STUDIO_BUCKET_NAME}",
#   "bucket": "${LABEL_STUDIO_BUCKET_NAME}",
#   "prefix": "/",
#   "use_blob_urls": true,
#   "presign": true,
#   "endpoint_url": "${LABEL_STUDIO_BUCKET_ENDPOINT_URL}",
#   "access_key": "${LABEL_STUDIO_BUCKET_ACCESS_KEY}",
#   "secret_key": "${LABEL_STUDIO_BUCKET_SECRET_KEY}",
#   "region": "us-east-1"
# }
# EOF

echo "=> Démarrage de Label Studio..."
 label-studio start -b -db postgresql --init "${LABEL_STUDIO_PROJECT_NAME}" --host 0.0.0.0 --port "${LABEL_STUDIO_PORT}" \
   --username "${LABEL_STUDIO_EMAIL}" --password "${LABEL_STUDIO_PASSWORD}" --user-token ${LABEL_STUDIO_API_KEY} \
  --database "${DATABASE_URL}" --log-level WARNING &

# --no-browser --config /label-studio/config/storage.json 
# Attendre que Label Studio soit prêt
echo "=> Attente de la disponibilité de Label Studio..."
until curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/projects" \
           -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" > /dev/null; do
  sleep 5
  echo "En attente de Label Studio..."
done

# Vérification si le projet existe
echo "=> Vérification si le projet '${LABEL_STUDIO_PROJECT_NAME}' existe..."
RESPONSE=$(curl -s -X GET "http://127.0.0.1:${LABEL_STUDIO_PORT}/api/projects" \
  -H "Authorization: Token ${LABEL_STUDIO_API_KEY}")
echo "Réponse brute de l'API : $RESPONSE"

PROJECT_ID=$(echo "$RESPONSE" | jq -r ".results[] | select(.title==\"${LABEL_STUDIO_PROJECT_NAME}\") | .id")

if [ -z "$PROJECT_ID" ]; then
  echo "=> Création du projet '${LABEL_STUDIO_PROJECT_NAME}'"
  curl -s -X POST "http://127.0.0.1:${LABEL_STUDIO_PORT}/api/projects" \
    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
          "title": "'"${LABEL_STUDIO_PROJECT_NAME}"'",
          "description": "Projet initialisé automatiquement",
          "label_config": "<View><Text name=\"text\" value=\"$text\"/></View>"
        }' > /dev/null
  RESPONSE=$(curl -s -X GET "http://127.0.0.1:${LABEL_STUDIO_PORT}/api/projects" \
    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}")
  PROJECT_ID=$(echo "$RESPONSE" | jq -r ".results[] | select(.title==\"${LABEL_STUDIO_PROJECT_NAME}\") | .id")
fi

if [ -z "$PROJECT_ID" ]; then
  echo "Erreur: Impossible de créer ou de récupérer le projet '${LABEL_STUDIO_PROJECT_NAME}'."
  exit 1
else
  echo "Projet '${LABEL_STUDIO_PROJECT_NAME}' ID: $PROJECT_ID"
fi

if [ -z "$PROJECT_ID" ]; then
  echo "Erreur: Impossible de créer ou de récupérer le projet '${LABEL_STUDIO_PROJECT_NAME}'."
  exit 1
else
  echo "Projet '${LABEL_STUDIO_PROJECT_NAME}' ID: $PROJECT_ID"
fi

# Configuration du stockage source S3
echo "=> Configuration du stockage source S3..."
SOURCE_STORAGE_ID=$(curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/storages/s3" \
                    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" | jq -r ".[] | select(.title==\"${LABEL_STUDIO_BUCKET_NAME}\" and .project==$PROJECT_ID) | .id")

if [ -z "$SOURCE_STORAGE_ID" ]; then
  echo "=> Ajout du stockage source S3..."
  curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/storages/s3" \
    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
      \"title\": \"${LABEL_STUDIO_BUCKET_NAME}\",
      \"bucket\": \"${LABEL_STUDIO_BUCKET_NAME}\",
      \"prefix\": \"${LABEL_STUDIO_BUCKET_PREFIX}\",
      \"use_blob_urls\": true,
      \"presign\": true,
      \"endpoint_url\": \"${LABEL_STUDIO_BUCKET_ENDPOINT_URL}\",
      \"access_key\": \"${LABEL_STUDIO_BUCKET_ACCESS_KEY}\",
      \"secret_key\": \"${LABEL_STUDIO_BUCKET_SECRET_KEY}\",
      \"region\": \"us-east-1\",
      \"project\": $PROJECT_ID,
      \"treat_every_file_as_task\": true
    }"
  echo "Stockage source S3 configuré."
else
  echo "Le stockage source S3 est déjà configuré."
fi

# Synchroniser les tâches depuis S3
echo "=> Synchronisation des tâches depuis S3..."
curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/storages/s3/${SOURCE_STORAGE_ID}/sync" \
  -H "Authorization: Token ${LABEL_STUDIO_API_KEY}"

# Configuration du stockage cible S3
echo "=> Configuration du stockage cible S3..."
TARGET_STORAGE_ID=$(curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/storages/s3" \
                    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" | jq -r ".[] | select(.title==\"${LABEL_STUDIO_TARGET_BUCKET}\" and .project==$PROJECT_ID) | .id")

if [ -z "$TARGET_STORAGE_ID" ]; then
  echo "=> Ajout du stockage cible S3..."
  curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/storages/s3" \
    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
      \"title\": \"${LABEL_STUDIO_TARGET_BUCKET}\",
      \"bucket\": \"${LABEL_STUDIO_TARGET_BUCKET}\",
      \"prefix\": \"${LABEL_STUDIO_TARGET_PREFIX}\",
      \"use_blob_urls\": false,
      \"presign\": true,
      \"endpoint_url\": \"${LABEL_STUDIO_BUCKET_ENDPOINT_URL}\",
      \"access_key\": \"${LABEL_STUDIO_BUCKET_ACCESS_KEY}\",
      \"secret_key\": \"${LABEL_STUDIO_BUCKET_SECRET_KEY}\",
      \"region\": \"us-east-1\",
      \"project\": $PROJECT_ID
    }"
  echo "Stockage cible S3 configuré."
else
  echo "Le stockage cible S3 est déjà configuré."
fi

# Ajout du backend GLiNER
echo "=> Ajout du backend GLiNER..."
ML_BACKEND_EXISTS=$(curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/ml" \
                    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" | jq -r ".[] | select(.title==\"GLiNER\" and .project==$PROJECT_ID) | .id")

if [ -z "$ML_BACKEND_EXISTS" ]; then
  echo "=> Connexion du modèle GLiNER..."
  curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/ml" \
    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
      \"url\": \"http://gliner:${MLBACKEND_PORT}\",
      \"title\": \"GLiNER\",
      \"description\": \"Modèle GLiNER pour NER\",
      \"project\": $PROJECT_ID
    }"
  echo "Modèle GLiNER connecté au projet '${LABEL_STUDIO_PROJECT_NAME}'"
else
  echo "Le backend GLiNER est déjà configuré pour le projet '${LABEL_STUDIO_PROJECT_NAME}'"
fi

# Maintenir le processus en cours
tail -f /dev/null

# gunicorn -w 4 -b 0.0.0.0:8081 core.wsgi:application