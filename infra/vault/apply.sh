#!/bin/sh
set -e

echo "[1/4] Enabling Kubernetes auth method..."
kubectl exec -n vault vault-2 -- vault auth enable kubernetes || true

echo "[2/4] Applying Kubernetes auth configuration..."
kubectl exec -n vault vault-2 -- sh -c '
  vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://${KUBERNETES_PORT_443_TCP_ADDR}:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
'

echo "[3/4] Applying Vault policy..."
kubectl exec -n vault vault-2 -- sh -c "cat << 'EOF' > /tmp/read-secret-policy.hcl
$(cat policies/read-secret-policy.hcl)
EOF
vault policy write read-secret-policy /tmp/read-secret-policy.hcl
"

echo "[4/4] Creating Vault role..."
kubectl exec -n vault vault-2 -- sh -c "cat << 'EOF' > /tmp/student-api-role.json
$(cat roles/student-api-role.json)
EOF
vault write auth/kubernetes/role/student-api @/tmp/student-api-role.json
"

echo "Vault configuration complete."
