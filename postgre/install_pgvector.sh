#!/bin/bash
set -e

# Check if the directory exists
if [ -d /tmp/pgvector ]; then
  cd /tmp/pgvector
else
  echo "Error: /tmp/pgvector directory does not exist."
  exit 1
fi

# Install pgvector
make && make install
