#!/bin/bash
set -e

# Log environment variables for debugging
echo "Vérification des variables d'environnement :"
echo "POSTGRES_USER=${POSTGRES_USER}"
echo "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}"
echo "POSTGRES_DB=${POSTGRES_DB}"
echo "MLFLOW_USER=${MLFLOW_USER}"
echo "MLFLOW_PASSWORD=${MLFLOW_PASSWORD}"
echo "MLFLOW_DB=${MLFLOW_DB}"
echo "LABEL_STUDIO_EMAIL=${LABEL_STUDIO_EMAIL}"
echo "LABEL_STUDIO_PASSWORD=${LABEL_STUDIO_PASSWORD}"
echo "LABEL_STUDIO_DB=${LABEL_STUDIO_DB}"

# Start PostgreSQL server
docker-entrypoint.sh postgres "$@" &

# Wait for PostgreSQL to start
until pg_isready -h localhost -p 5432; do
  echo "Waiting for PostgreSQL to start..."
  sleep 2
done

# # Initialize pgvector
# if [ -d /tmp/pgvector ]; then
#   cd /tmp/pgvector
#   make && make install
# else
#   echo "pgvector directory not found!"
# fi

# Substitute environment variables in SQL template and create a processed SQL file
if [ -f /docker-entrypoint-initdb.d/init_db.sql.template ]; then
  echo "Substituting variables in init_db.sql.template..."
  envsubst < /docker-entrypoint-initdb.d/init_db.sql.template > /docker-entrypoint-initdb.d/init_db.sql
  echo "Fichier SQL généré :"
  cat /docker-entrypoint-initdb.d/init_db.sql
else
  echo "Template file init_db.sql.template not found!"
  exit 1
fi

# Initialize the database using the processed SQL file
if [ -f /docker-entrypoint-initdb.d/init_db.sql ]; then
  psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -f /docker-entrypoint-initdb.d/init_db.sql
fi

# Wait for the PostgreSQL process to finish
wait