#!/bin/sh
set -e

TARGET_NAMESPACE=${1:-student-api-staging}
VAULT_ADDR=${VAULT_ADDR:-http://127.0.0.1:8200}
VAULT_TOKEN=${VAULT_TOKEN:-root}

echo "Configuring Vault for namespace: $TARGET_NAMESPACE"

vault_exec() {
  kubectl exec -n vault vault-0 -- sh -c "$1"
}

echo "[1/4] Checking Kubernetes auth method..."
vault_exec "vault auth list" | grep -q "kubernetes/" || \
  vault_exec "vault auth enable kubernetes"

echo "[2/4] Applying Kubernetes auth configuration..."
vault_exec "
  vault write auth/kubernetes/config \
    token_reviewer_jwt=\"\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)\" \
    kubernetes_host=\"https://\$KUBERNETES_SERVICE_HOST:443\" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
"

echo "[3/4] Applying Vault policy..."
kubectl cp vault/policies/read-secret-policy.hcl vault/vault-0:/tmp/read-secret-policy.hcl
kubectl exec -n vault vault-0 -- \
  vault policy write read-secret-policy /tmp/read-secret-policy.hcl

echo "[4/4] Creating Vault role for ESO in $TARGET_NAMESPACE..."
vault_exec "
  vault write auth/kubernetes/role/student-api \
    bound_service_account_names=external-secrets \
    bound_service_account_namespaces=\"external-secrets,$TARGET_NAMESPACE\" \
    policies=read-secret-policy \
    ttl=24h
"

echo "Vault configuration complete for $TARGET_NAMESPACE."