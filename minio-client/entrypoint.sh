#!/bin/bash
set -e

# Set environment variables for MinIO
export MINIO_PORT=${MINIO_PORT}
export MINIO_ROOT_USER=${MINIO_ROOT_USER}
export MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}
LABELSTUDIO_USER="labelstudio"
LABELSTUDIO_PASSWORD="labelstudio123"


# Set proxy environment variables if available
export HTTP_PROXY=${HTTP_PROXY}
export HTTPS_PROXY=${HTTPS_PROXY}

echo "Configuration de l'alias MinIO..."
mc alias set myminio http://minio:${MINIO_PORT} ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD} || {
  echo "Échec de la configuration de l'alias MinIO"
  exit 1
}

echo "Création des buckets..."
mc mb myminio/data || echo "Bucket 'labelstudio' existe déjà."
mc mb myminio/mlflow || echo "Bucket 'labelstudio' existe déjà."
mc mb myminio/labelstudio || echo "Bucket 'labelstudio' existe déjà."
mc mb myminio/labelstudio-input || true
mc mb myminio/labelstudio-output || true

echo "Configuration des politiques de MinIO..."
mc anonymous set public myminio/data || echo "Échec de la configuration de la politique publique pour 'data'"
mc anonymous set public myminio/mlflow || echo "Échec de la configuration de la politique publique pour 'mlflow'"
mc anonymous set public myminio/labelstudio || echo "Échec de la configuration de la politique publique pour 'labelstudio'"
mc anonymous set public myminio/labelstudio-input || true
mc anonymous set public myminio/labelstudio-output || true
mc policy set download myminio/labelstudio-input || echo "Échec de la configuration de la politique de téléchargement pour 'labelstudio-input'"
mc policy set download myminio/labelstudio-output || echo "Échec de la configuration de la politique de téléchargement pour 'labelstudio-output'"
mc policy set download myminio/labelstudio || echo "Échec de la configuration de la politique de téléchargement pour 'labelstudio'"
mc policy set download myminio/data || echo "Échec de la configuration de la politique de téléchargement pour 'data'"



echo "Création de l'utilisateur Label Studio..."
mc admin user add myminio ${LABELSTUDIO_USER} ${LABELSTUDIO_PASSWORD} || echo "Utilisateur Label Studio existe déjà."

echo "Création d'une politique personnalisée pour Label Studio..."
cat <<EOF > /tmp/labelstudio-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::labelstudio",
        "arn:aws:s3:::labelstudio-input",
        "arn:aws:s3:::labelstudio-output"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::labelstudio/*",
        "arn:aws:s3:::labelstudio-input/*",
        "arn:aws:s3:::labelstudio-output/*"
      ]
    }
  ]
}
EOF

mc admin policy create myminio labelstudio-policy /tmp/labelstudio-policy.json || echo "Politique existe déjà."

echo "Association de la politique à l'utilisateur Label Studio..."
mc admin policy attach myminio labelstudio-policy --user ${LABELSTUDIO_USER}



# echo "=> Applying CORS policy to MinIO"
# if [ -f /label-studio/cors.json ]; then
#   mc admin policy create myminio cors /label-studio/cors.json || echo "CORS policy already applied."
# else
#   echo "CORS policy file not found at /label-studio/cors.json"
# fi

# Keep container alive
tail -f /dev/null
