#!/bin/bash

set -euo pipefail

minikube start --driver="docker" --nodes=3 -p minii-cluster

kubectl label node minii-cluster type=application
kubectl label node minii-cluster-m02 type=database
kubectl label node minii-cluster-m03 type=dependent_service

minikube addons enable ingress -p minii-cluster

echo "======================================================"
echo " Bootstrapping Cluster (Vault + ESO + Infra + App)    "
echo "======================================================"
###
##################################################
#### 1. INSTALL EXTERNAL SECRETS OPERATOR (CRDs)
##################################################
echo "[1/6] Installing External Secrets Operator..."

helm repo add external-secrets https://charts.external-secrets.io >/dev/null 2>&1
helm repo update >/dev/null 2>&1

helm upgrade --install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace


##################################################
#### 2. INSTALL VAULT VIA HELM (NOT CONFIGURED YET)
##################################################
echo "[2/6] Installing Vault..."
helm repo add hashicorp https://helm.releases.hashicorp.com >/dev/null 2>&1
helm repo update >/dev/null 2>&1

helm upgrade --install vault hashicorp/vault \
  -n vault --create-namespace \
  -f vault/values-dev.yaml


#################################################
### 3. INSTALL INFRA CHART (ClusterSecretStore)
#################################################
echo "[3/6] Installing infra chart..."

helm upgrade --install infra ../charts/infra \
  -n infra --create-namespace

################################################
## 4. WAIT FOR VAULT TO BE READY
################################################
echo "[4/6] Waiting for vault-0 pod to be ready..."

kubectl wait --for=condition=Ready pod/vault-0 \
  -n vault --timeout=180s


###############################################
# 5. RUN VAULT CONFIGURATION SCRIPT
###############################################
echo "[5/6] Running Vault configuration apply.sh..."

chmod +x vault/apply.sh
./vault/apply.sh

###############################################
# 5.1. SEED VAULT SECRETS
###############################################
echo "[5.1/6] Seeding Vault secrets..."
chmod +x vault/seed-secrets.sh
./vault/seed-secrets.sh


###############################################
# 6. INSTALL APPLICATION
###############################################
echo "[6/6] Installing student-api chart..."

helm install student-app ../charts/student-app \
  -n student-api-staging --create-namespace \
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
