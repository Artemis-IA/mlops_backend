#!/bin/bash
set -e

exec entrypoint-postgres.sh "$@"
