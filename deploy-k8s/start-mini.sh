#!/usr/bin/env bash

set -e pipefail

minikube start --nodes=3 -p minii-cluster
kubectl label node minii-cluster type=application
kubectl label node minii-cluster-m02 type=database
kubectl label node minii-cluster-m03 type=dependent_service
