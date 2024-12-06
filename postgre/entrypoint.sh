#!/bin/bash
set -e

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
  envsubst < /docker-entrypoint-initdb.d/init_db.sql.template > /docker-entrypoint-initdb.d/init_db.sql
fi

# Initialize the database using the processed SQL file
if [ -f /docker-entrypoint-initdb.d/init_db.sql ]; then
  psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -f /docker-entrypoint-initdb.d/init_db.sql
fi

# Wait for the PostgreSQL process to finish
wait