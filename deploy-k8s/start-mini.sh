#!/usr/bin/env bash

set -euo pipefail

minikube start --driver="docker" --nodes=3 -p minii-cluster

kubectl label node minii-cluster type=application
kubectl label node minii-cluster-m02 type=database
kubectl label node minii-cluster-m03 type=dependent_service
