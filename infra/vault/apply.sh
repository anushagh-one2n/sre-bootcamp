#!/bin/sh
set -e

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root

echo "[1/4] Enabling Kubernetes auth method..."
kubectl exec -n vault vault-0 -- vault auth enable kubernetes || true

echo "[2/4] Applying Kubernetes auth configuration..."
kubectl exec -n vault vault-0 -- sh -c "
  vault write auth/kubernetes/config \
    token_reviewer_jwt='$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)' \
    kubernetes_host='https://${KUBERNETES_PORT_443_TCP_ADDR}:443' \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
"

echo "[3/4] Applying Vault policy..."
kubectl exec -n vault vault-0 -- sh -c "cat << 'EOF' > /tmp/read-secret-policy.hcl
$(cat policies/read-secret-policy.hcl)
EOF
vault policy write read-secret-policy /tmp/read-secret-policy.hcl
"

echo "[4/4] Creating Vault role for ESO..."
kubectl exec -n vault vault-0 -- \
vault write auth/kubernetes/role/student-api \
  bound_service_account_names=external-secrets \
  bound_service_account_namespaces=external-secrets \
  policies=read-secret-policy \
  ttl=24h

echo "Vault configuration complete."
