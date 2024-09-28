#!/bin/bash
set -e

exec docker-entrypoint.sh postgres "$@"
