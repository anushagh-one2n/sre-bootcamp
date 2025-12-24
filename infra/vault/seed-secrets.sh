#!/bin/sh
set -euo pipefail

###############################################
# Load environment variables
###############################################

ENV_FILE="vault/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE not found. Aborting."
  exit 1
fi

# Export all vars from .env
set -a
. "$ENV_FILE"
set +a

###############################################
# Validate required variables
###############################################

: "${VAULT_ADDR:?Missing VAULT_ADDR}"
: "${VAULT_TOKEN:?Missing VAULT_TOKEN}"

: "${DOCKERHUB_USERNAME:?Missing DOCKERHUB_USERNAME}"
: "${DOCKERHUB_PASSWORD:?Missing DOCKERHUB_PASSWORD}"
: "${DOCKERHUB_EMAIL:?Missing DOCKERHUB_EMAIL}"

: "${DB_USERNAME:?Missing DB_USERNAME}"
: "${DB_PASSWORD:?Missing DB_PASSWORD}"

###############################################
# Verify Vault connectivity
###############################################

kubectl exec -n vault vault-0 -- sh -c "
export VAULT_ADDR=$VAULT_ADDR
export VAULT_TOKEN=$VAULT_TOKEN

vault kv put secret/dockerhub \
  username=$DOCKERHUB_USERNAME \
  password=$DOCKERHUB_PASSWORD \
  email=$DOCKERHUB_EMAIL

vault kv put secret/student-api/db \
  username=$DB_USERNAME \
  password=$DB_PASSWORD
"