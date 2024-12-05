#!/bin/bash
set -e

# Vérification des variables d'environnement essentielles
REQUIRED_ENV_VARS=("LABEL_STUDIO_API_KEY" "LABEL_STUDIO_EMAIL" "LABEL_STUDIO_PASSWORD" "POSTGRES_HOST" "POSTGRES_PORT" "POSTGRES_DB" "LABEL_STUDIO_BUCKET_ENDPOINT_URL" "LABEL_STUDIO_BUCKET_ACCESS_KEY" "LABEL_STUDIO_BUCKET_SECRET_KEY")
for var in "${REQUIRED_ENV_VARS[@]}"; do
  if [[ -z "${!var}" ]]; then
    echo "ERREUR : La variable d'environnement $var est manquante. Arrêt du script."
    exit 1
  fi
done

# Définir LABEL_STUDIO_HOST par défaut si non défini
if [[ -z "${LABEL_STUDIO_HOST}" ]]; then
  export LABEL_STUDIO_HOST="http://0.0.0.0"
fi

# Attente de la disponibilité de PostgreSQL
echo "=> En attente de la disponibilité de PostgreSQL..."
until pg_isready -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}"; do
  sleep 5
  echo "PostgreSQL n'est pas encore prêt..."
done
echo "PostgreSQL est disponible."

# Configuration de l'URL de la base de données
export DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
echo "DATABASE_URL=${DATABASE_URL}"

# Vérification de la disponibilité de MinIO
echo "=> Waiting for MinIO to be available..."
until curl -s "${LABEL_STUDIO_BUCKET_ENDPOINT_URL}" > /dev/null; do
  echo "Waiting for MinIO..."
  sleep 5
done
echo "MinIO is available."


# Démarrage de Label Studio
echo "=> Démarrage de Label Studio..."
label-studio start -b -db postgresql \
    --init "${LABEL_STUDIO_PROJECT_NAME}" \
    --host 0.0.0.0 \
    --port "${LABEL_STUDIO_PORT}" \
    --username "${LABEL_STUDIO_EMAIL}" \
    --password "${LABEL_STUDIO_PASSWORD}" \
    --user-token "${LABEL_STUDIO_API_KEY}" \
    --database "${DATABASE_URL}" \
    --log-level WARNING &

# Attente que Label Studio soit prêt
echo "=> Attente de la disponibilité de Label Studio..."
until curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/projects" \
           -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" > /dev/null; do
  sleep 5
  echo "En attente de Label Studio..."
done

# Vérification si le projet existe
echo "=> Vérification si le projet '${LABEL_STUDIO_PROJECT_NAME}' existe..."
RESPONSE=$(curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/projects" \
  -H "Authorization: Token ${LABEL_STUDIO_API_KEY}")
PROJECT_ID=$(echo "$RESPONSE" | jq -r ".results[] | select(.title==\"${LABEL_STUDIO_PROJECT_NAME}\") | .id")

if [[ -z "$PROJECT_ID" ]]; then
  echo "=> Création du projet '${LABEL_STUDIO_PROJECT_NAME}'"
  curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/projects" \
    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
      \"title\": \"${LABEL_STUDIO_PROJECT_NAME}\",
      \"description\": \"Projet initialisé automatiquement\",
      \"label_config\": \"<View><Text name='text' value='$text'/></View>\"
    }" > /dev/null
  RESPONSE=$(curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/projects" \
    -H "Authorization: Token ${LABEL_STUDIO_API_KEY}")
  PROJECT_ID=$(echo "$RESPONSE" | jq -r ".results[] | select(.title==\"${LABEL_STUDIO_PROJECT_NAME}\") | .id")
fi

if [[ -z "$PROJECT_ID" ]]; then
  echo "Erreur: Impossible de créer ou de récupérer le projet '${LABEL_STUDIO_PROJECT_NAME}'."
  exit 1
else
  echo "Projet '${LABEL_STUDIO_PROJECT_NAME}' ID: $PROJECT_ID"
fi

# # Configuration du stockage source S3
# echo "=> Configuration du stockage source S3..."
# RESPONSE=$(curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/storages/s3" \
#   -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" \
#   -H "Content-Type: application/json" \
#   -d "{
#     \"title\": \"${LABEL_STUDIO_BUCKET_NAME}\",
#     \"bucket\": \"${LABEL_STUDIO_BUCKET_NAME}\",
#     \"prefix\": \"${LABEL_STUDIO_BUCKET_PREFIX}\",
#     \"use_blob_urls\": true,
#     \"presign\": true,
#     \"endpoint_url\": \"${LABEL_STUDIO_BUCKET_ENDPOINT_URL}\",
#     \"access_key\": \"${LABEL_STUDIO_BUCKET_ACCESS_KEY}\",
#     \"secret_key\": \"${LABEL_STUDIO_BUCKET_SECRET_KEY}\",
#     \"region\": \"us-east-1\",
#     \"project\": $PROJECT_ID
#   }")
# echo "Réponse configuration S3 : $RESPONSE"

# # Synchronisation des tâches depuis S3
# echo "=> Synchronisation des tâches depuis S3..."
# curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/storages/s3/sync" \
#   -H "Authorization: Token ${LABEL_STUDIO_API_KEY}"

# # Configuration du stockage source S3 via script Python
# echo "=> Configuration du stockage source S3 via script Python..."
# python3 /label-studio/create_bucket.py

# # Ajout du backend GLiNER
# echo "=> Ajout du backend GLiNER..."
# ML_BACKEND_EXISTS=$(curl -s "http://localhost:${LABEL_STUDIO_PORT}/api/ml" \
#   -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" | jq -r ".[] | select(.title==\"GLiNER\" and .project==$PROJECT_ID) | .id")

# if [[ -z "$ML_BACKEND_EXISTS" ]]; then
#   echo "=> Connexion du modèle GLiNER..."
#   curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/ml" \
#     -H "Authorization: Token ${LABEL_STUDIO_API_KEY}" \
#     -H "Content-Type: application/json" \
#     -d "{
#       \"url\": \"http://gliner:${MLBACKEND_PORT}\",
#       \"title\": \"GLiNER\",
#       \"description\": \"Modèle GLiNER pour NER\",
#       \"project\": $PROJECT_ID
#     }"
#   echo "Backend GLiNER ajouté au projet '${LABEL_STUDIO_PROJECT_NAME}'."
# else
#   echo "Le backend GLiNER est déjà configuré."
# fi

# Maintenir le processus en cours
tail -f /dev/null
! HOST variable found in environment, but it must start with http:// or https://, ignore it: labelstudio.mlops.bzh