#!/bin/bash

# Start Label Studio in the background
label-studio &

# Wait for Label Studio to start
sleep 30

# Check if the superuser exists and create if necessary
label-studio shell -c "
from users.models import User;
from rest_framework.authtoken.models import Token;

if not User.objects.filter(username='$LABEL_STUDIO_USERNAME').exists():
    User.objects.create_superuser('$LABEL_STUDIO_USERNAME', '$LABEL_STUDIO_USER_EMAIL', '$LABEL_STUDIO_PASSWORD')
    print('Superuser created successfully.')
else:
    print('Superuser already exists.')

user = User.objects.get(username='$LABEL_STUDIO_USERNAME')
token, _ = Token.objects.get_or_create(user=user)
print(f'API Key for {user.username}: {token.key}')
" || { echo "Error: Failed to create or verify superuser"; exit 1; }

# Save the API key in a JSON file
API_KEY=$(label-studio shell -c "
from users.models import User;
from rest_framework.authtoken.models import Token;
user = User.objects.get(username='$LABEL_STUDIO_USERNAME');
token = Token.objects.get(user=user);
print(token.key)
" | tail -n 1)

if [ -z "$API_KEY" ]; then
  echo "Error: Failed to retrieve API key for user $LABEL_STUDIO_USERNAME"
  exit 1
fi

# Store the API key in a JSON file
echo "API key generated: $API_KEY"
cat <<EOF > /label-studio/data/label_studio_api_key.json
{
  "username": "$LABEL_STUDIO_USERNAME",
  "api_key": "$API_KEY"
}
EOF

echo "API key saved to /label-studio/data/label_studio_api_key.json"

# Keep Label Studio running
wait
