#!/bin/bash
set -e

# Afficher les variables d'environnement
echo "=> Starting Label Studio with the following environment:"
echo "   LABEL_STUDIO_USERNAME=${LABEL_STUDIO_USERNAME}"
echo "   LABEL_STUDIO_PASSWORD=${LABEL_STUDIO_PASSWORD}"
echo "   LABEL_STUDIO_API_KEY=${LABEL_STUDIO_API_KEY}"
echo "   LABEL_STUDIO_BUCKET_NAME=${LABEL_STUDIO_BUCKET_NAME}"
echo "   LABEL_STUDIO_BUCKET_ENDPOINT_URL=${LABEL_STUDIO_BUCKET_ENDPOINT_URL}"
echo "   LABEL_STUDIO_BUCKET_ACCESS_KEY=${LABEL_STUDIO_BUCKET_ACCESS_KEY}"
echo "   LABEL_STUDIO_BUCKET_SECRET_KEY=${LABEL_STUDIO_BUCKET_SECRET_KEY}"
echo "   AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}"



# Configurer la base de données et le répertoire des médias
echo "=> Database and media directory: /label-studio/data"

# Créer un superutilisateur si nécessaire (en démarrant Label Studio en arrière-plan pour configurer l'utilisateur)
echo "=> Creating superuser if not exists"
label-studio start --username "${LABEL_STUDIO_USERNAME}" --password "${LABEL_STUDIO_PASSWORD}" --no-browser &

# Attendre que Label Studio soit disponible
echo "=> Waiting for Label Studio to be available..."
until curl -s http://localhost:${LABEL_STUDIO_PORT}/ > /dev/null; do
  echo "Waiting for Label Studio..."
  sleep 5
done

# Générer un token pour l'utilisateur admin_user (nécessaire pour l'API)
echo "=> Generating API token for user ${LABEL_STUDIO_USERNAME}"
LABEL_STUDIO_USER_TOKEN=$(curl -s -X POST "http://localhost:${LABEL_STUDIO_PORT}/user/token/" \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"${LABEL_STUDIO_USERNAME}\", \"password\": \"${LABEL_STUDIO_PASSWORD}\"}" | jq -r '.token')

if [ -z "${LABEL_STUDIO_USER_TOKEN}" ]; then
  echo "Error: Unable to generate user token. Exiting..."
  exit 1
else
  echo "Successfully generated token: ${LABEL_STUDIO_USER_TOKEN}"
fi

# Configurer automatiquement MinIO comme stockage via l'API Label Studio
echo "=> Configuring MinIO as storage for Label Studio"
curl -X POST "http://localhost:${LABEL_STUDIO_PORT}/api/storages/s3" \
  -H "Authorization: Token ${LABEL_STUDIO_USER_TOKEN}" \
  -d "title=${LABEL_STUDIO_BUCKET_NAME}" \
  -d "bucket=${LABEL_STUDIO_BUCKET_NAME}" \
  -d "prefix=/" \
  -d "use_blob_urls=true" \
  -d "presign=true" \
  -d "endpoint_url=${LABEL_STUDIO_BUCKET_ENDPOINT_URL}" \
  -d "access_key=${LABEL_STUDIO_BUCKET_ACCESS_KEY}" \
  -d "secret_key=${LABEL_STUDIO_BUCKET_SECRET_KEY}" \
  -d "region=${AWS_DEFAULT_REGION}" || true

# Attendre quelques secondes pour s'assurer que la configuration est appliquée
sleep 5

# Lancer le serveur Label Studio en premier plan
echo "=> Starting Label Studio"
exec label-studio start --host 0.0.0.0 --port "${LABEL_STUDIO_PORT}" --no-browser
