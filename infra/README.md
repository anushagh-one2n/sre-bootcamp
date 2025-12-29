# Cluster Bootstrap

This directory contains the bootstrap script used to provision a complete local Kubernetes environment using **Minikube
**, **Vault**, **External Secrets Operator (ESO)**, **Ingress**, and **ArgoCD**.  
Application deployment is now fully GitOps-driven via ArgoCD – the bootstrap script does **not** install the
application.

---

## What the Bootstrap Script Does

The script performs the following steps in order:

1. Starts a multi-node Minikube cluster
2. Labels nodes for application, database, and dependent services
3. Enables the NGINX Ingress addon
4. Installs External Secrets Operator (CRDs + controller)
5. Installs Vault via Helm (unconfigured)
6. Installs the `infra` Helm chart
7. Configures Vault Kubernetes auth, policies, and roles
8. Seeds initial secrets into Vault
9. Installs **ArgoCD**
10. Applies ArgoCD bootstrap manifests (repo-secret + root-app)
11. ArgoCD then automatically deploys the `student-app` chart

> The student application is no longer deployed inside this script using Helm.  
> Deployment now happens only through GitOps → ArgoCD reading from Git.

---

## Prerequisites

- Ensure the following are installed locally:
    - Docker
    - Minikube
    - kubectl
    - Helm v3+
    - GitHub PAT stored inside Vault at `argocd/github` (token required for ArgoCD repo access)

- Ensure that you have created a copy of [.env.example](vault/.env.example) and saved it as .env with the appropriate
  values.

---

## Usage

Run the bootstrap from the [infra/](/infra) directory:

```bash
cd infra
./bootstrap.sh
```

---

## Cluster Details:

- Installed Components
    - External Secrets Operator
        - Used to sync secrets from Vault into Kubernetes
    - Vault
        - Configured using Kubernetes auth
        - Policies and roles applied via scripts under infra/vault/
    - Infra Helm Chart
        - Installs shared cluster-level resources
        - Includes ClusterSecretStore and related objects
    - ArgoCD
        - Installed during bootstrap
        - Watches this Git repository for changes and applies them to the cluster
    - Student Application
        - Automatically deployed into student-api-staging namespace by ArgoCD
        - Uses Helm chart under charts/student-app
        - Consumes secrets sourced from Vault via ESO

## Post bootstrap script actions:

- To access the apis:
    - Port forward the ingress to hit the apis as follows: \
      `kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80`
    - Host: `student-api.local:8080` (so apis can be accessed as: http://student-api.local:8080/api/v1/students/1 etc)

- To update the vault secrets:
    - Via ui:
        - Port forward vault using: `kubectl port-forward -n vault vault-0 8200:8200` and access the ui
          at http://localhost:8200
        - Either update the secrets via ui by creating a new version of the secret or by using the vault cli to update
          it: eg:
            ```
            vault kv put secret/student-api/db \
            username=<db-username> \
            password=<db-password>
          ```
    - By exec-ing into the vault pod:
        - Exec into vault pod using  `kubectl exec -n vault -it vault-0 -- sh`
        - Use the cli command above to update the secret

- PS:
  - Application deployments must never be done manually via helm.
    - Git commit updates → CI builds image → GitOps CD workflow updates Helm → ArgoCD syncs → cluster updates.