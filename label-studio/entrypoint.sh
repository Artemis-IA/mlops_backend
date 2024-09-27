#!/bin/bash

# Start Label Studio in the background
label-studio &

# Wait for Label Studio to be fully started (increase delay if necessary)
sleep 30

echo "Checking if the admin user exists..."

# Create the superuser using label-studio's user creation method
label-studio user --username "$DJANGO_SUPERUSER_USERNAME" --password "$DJANGO_SUPERUSER_PASSWORD" || {
    echo "Error: Failed to create or verify the superuser"
    exit 1
}

# Fetch the API key for the superuser
echo "Fetching the API key for the superuser..."
API_KEY=$(label-studio user --username "$DJANGO_SUPERUSER_USERNAME" | grep 'token' | awk '{print $2}')

# Verify if the API key has been generated
if [ -z "$API_KEY" ]; then
  echo "Error: Unable to retrieve the API key for user $DJANGO_SUPERUSER_USERNAME"
  exit 1
fi

# Display the generated API key
echo "API key generated: $API_KEY"

# Save the API key in a JSON file
API_JSON=$(cat <<EOF
{
  "username": "$DJANGO_SUPERUSER_USERNAME",
  "api_key": "$API_KEY"
}
EOF
)

echo "$API_JSON" > ./label_studio_api_key.json
echo "The API key has been saved to ./label_studio_api_key.json"

# Keep Label Studio running in the foreground
wait
