#!/bin/bash

set -euo pipefail

minikube start --driver="docker" --nodes=3 -p minii-cluster

kubectl label node minii-cluster type=application --overwrite
kubectl label node minii-cluster-m02 type=database  --overwrite
kubectl label node minii-cluster-m03 type=dependent_service  --overwrite

minikube addons enable ingress -p minii-cluster

echo "======================================================"
echo " Bootstrapping Cluster (Vault + ESO + Infra + App)    "
echo "======================================================"
###
##################################################
#### 1. INSTALL EXTERNAL SECRETS OPERATOR (CRDs)
##################################################
echo "[1/7] Installing External Secrets Operator..."

helm repo add external-secrets https://charts.external-secrets.io --force-update >/dev/null 2>&1
helm repo update >/dev/null 2>&1

helm upgrade --install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace --wait


##################################################
#### 2. INSTALL VAULT VIA HELM (NOT CONFIGURED YET)
##################################################
echo "[2/7] Installing Vault..."
helm repo add hashicorp https://helm.releases.hashicorp.com --force-update >/dev/null 2>&1
helm repo update >/dev/null 2>&1

helm upgrade --install vault hashicorp/vault \
  -n vault --create-namespace \
  -f vault/values-dev.yaml --wait


#################################################
### 3. INSTALL INFRA CHART (ClusterSecretStore)
#################################################
echo "[3/7] Installing infra chart..."

helm upgrade --install infra ../charts/infra \
  -n infra --create-namespace --wait

################################################
## 4. WAIT FOR VAULT TO BE READY
################################################
echo "[4/7] Waiting for vault-0 pod to be ready..."

kubectl wait --for=condition=Ready pod/vault-0 \
  -n vault --timeout=180s


###############################################
# 5. RUN VAULT CONFIGURATION SCRIPT
###############################################
echo "[5/7] Running Vault configuration apply.sh..."

chmod +x vault/apply.sh
./vault/apply.sh

###############################################
# 5.1. SEED VAULT SECRETS
###############################################
echo "[5.1/7] Seeding Vault secrets..."
chmod +x vault/seed-secrets.sh
./vault/seed-secrets.sh


###############################################
# 6. INSTALL ARGOCD
###############################################
echo "[6/7] Installing ArgoCD via Helm..."

helm repo add argo https://argoproj.github.io/argo-helm --force-update >/dev/null 2>&1
helm repo update >/dev/null 2>&1

helm upgrade --install argocd argo/argo-cd \
  -n argocd --create-namespace \
  -f ../argocd/values.yaml \
  --wait


############################################
# Apply declarative GitOps manifests
############################################
echo "[7/7] Applying ArgoCD bootstrap objects..."

kubectl apply -f ../argocd/repo-secrets/
kubectl apply -f ../argocd/applications/root.yaml
