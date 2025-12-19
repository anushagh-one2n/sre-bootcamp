#!/bin/bash

set -euo pipefail

#minikube start --driver="docker" --nodes=3 -p minii-cluster
#
#kubectl label node minii-cluster type=application
#kubectl label node minii-cluster-m02 type=database
#kubectl label node minii-cluster-m03 type=dependent_service

#
##minikube addons enable ingress -p minii-cluster
##
#echo "======================================================"
#echo " Bootstrapping Cluster (Vault + ESO + Infra + App)    "
#echo "======================================================"
#
################################################
## 1. INSTALL EXTERNAL SECRETS OPERATOR (CRDs)
################################################
#echo "[1/7] Installing External Secrets Operator..."
#
#helm repo add external-secrets https://charts.external-secrets.io >/dev/null 2>&1
#helm repo update >/dev/null 2>&1
#
#helm upgrade --install external-secrets external-secrets/external-secrets \
#  -n external-secrets --create-namespace
#
#
################################################
## 2. INSTALL VAULT VIA HELM (NOT CONFIGURED YET)
################################################
echo "[2/7] Installing Vault..."
helm repo add hashicorp https://helm.releases.hashicorp.com >/dev/null 2>&1
helm repo update >/dev/null 2>&1

helm upgrade --install vault hashicorp/vault \
  -n vault --create-namespace \
  -f vault/values-ha.yaml
#
#
################################################
## 3. PREPARE DOCKERHUB CREDENTIALS SECRET
################################################
#echo "[3/7] Creating DockerHub registry secret..."
#
## Expected ENV variables:
##   DOCKERHUB_USERNAME
##   DOCKERHUB_PASSWORD
##   DOCKERHUB_EMAIL (optional)
#
#
#if [[ -z "$DOCKERHUB_USERNAME" || -z "$DOCKERHUB_PASSWORD" ]]; then
#  echo "ERROR: DOCKERHUB_USERNAME and DOCKERHUB_PASSWORD must be set."
#  exit 1
#fi
#
#
#kubectl create namespace student-api --dry-run=client -o yaml | kubectl apply -f -
#
#
#
#kubectl delete secret dockerhub-creds -n student-api --ignore-not-found >/dev/null 2>&1
#kubectl create secret docker-registry dockerhub-creds \
#  --docker-username="$DOCKERHUB_USERNAME" \
#  --docker-password="$DOCKERHUB_PASSWORD" \
#  --docker-email="${DOCKERHUB_EMAIL:-dev@example.com}" \
#  -n student-api


###############################################
# 4. INSTALL INFRA CHART (ClusterSecretStore)
###############################################
#echo "[4/7] Installing infra chart..."
#
#helm upgrade --install infra ../charts/infra \
#  -n infra --create-namespace


###############################################
# 5. WAIT FOR VAULT TO BE READY
###############################################
echo "[5/7] Waiting for vault-0 pod to be ready..."

kubectl wait --for=condition=Ready pod/vault-0 \
  -n vault --timeout=180s


###############################################
# 6. RUN VAULT CONFIGURATION SCRIPT
###############################################
echo "[6/7] Running Vault configuration apply.sh..."

chmod +x vault/apply.sh
./vault/apply.sh


###############################################
# 7. INSTALL APPLICATION
###############################################
echo "[7/7] Installing student-api chart..."

helm upgrade --install student-api charts/student-api \
  -n student-api --create-namespace \
  --set image.pullSecrets[0]=dockerhub-creds


echo ""
echo "======================================================"
echo " Bootstrap Complete                                  "
echo "======================================================"
echo "Next Steps:"
echo "  1. Port-forward Vault UI:"
echo "       kubectl port-forward -n vault vault-0 8200:8200"
echo "  2. Login with your root token"
echo "  3. Insert real secrets into Vault:"
echo "       vault kv put secret/student-api/db username=... password=..."
echo ""
