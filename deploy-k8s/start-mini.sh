#!/usr/bin/env bash

set -euo pipefail

minikube start --driver="docker" --nodes=3 -p minii-cluster

kubectl label node minii-cluster type=application
kubectl label node minii-cluster-m02 type=database
kubectl label node minii-cluster-m03 type=dependent_service


kubectl apply -f manifests/database.yaml

kubectl apply -f manifests/application.yaml

kubectl apply -f manifests/ingress.yaml

kubectl create secret generic db-credentials \
  --from-env-file=secrets/db.env \
  -n student-api \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets created successfully."

minikube addons enable ingress --profile minii-cluster