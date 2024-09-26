#!/bin/bash

# Démarrer Label Studio en arrière-plan
label-studio &

# Attendre que Label Studio soit entièrement démarré
sleep 20  # Augmenter le délai pour s'assurer que tout est prêt

# Vérifier si l'utilisateur admin existe
label-studio shell -c "
from users.models import User;
if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', '$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD');
"

# Récupérer la clé API du superutilisateur
API_KEY=$(label-studio shell -c "
from users.models import User;
user = User.objects.get(username='$DJANGO_SUPERUSER_USERNAME');
print(user.auth_token.key);
")

# Vérifier si la clé API a bien été générée
if [ -z "$API_KEY" ]; then
  echo "Erreur : Impossible de récupérer la clé API pour l'utilisateur $DJANGO_SUPERUSER_USERNAME"
  exit 1
fi

# Afficher la clé API pour vérification
echo "Clé API générée : $API_KEY"

# Créer un fichier JSON avec la clé API
API_JSON=$(cat <<EOF
{
  "username": "$DJANGO_SUPERUSER_USERNAME",
  "api_key": "$API_KEY"
}
EOF
)

# Sauvegarder le fichier JSON dans le répertoire courant
echo "$API_JSON" > ./label_studio_api_key.json

# Afficher le chemin du fichier JSON
echo "La clé API a été sauvegardée dans le fichier ./label_studio_api_key.json"

# Garder le service Label Studio en avant-plan pour éviter que le container ne s'arrête
wait
