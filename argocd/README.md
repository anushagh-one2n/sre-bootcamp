# ArgoCD Configuration

This directory contains all ArgoCD configuration used for GitOps-based deployment of the application.

ArgoCD watches this repository and applies changes automatically. Nothing in this directory is created manually in the
UI; all changes originate from Git.

---

## How it works:

- During bootstrap ([infra/bootstrap.sh](../infra/bootstrap.sh)), ArgoCD is installed and the root application is
  applied.
- The file [applications/root.yaml](applications/root.yaml) points ArgoCD to this repo path and registers child apps.
- [student-app.yaml](applications/student-app.yaml) defines the actual Helm chart deployment
  under [charts/student-app/](../charts/student-app).
- When Helm values in [charts/student-app/values.yaml](../charts/student-app/values.yaml) change, ArgoCD detects the
  commit and redeploys automatically.

---

## When Changes Take Effect

- Editing any file under [argocd/applications/](applications) → changes ArgoCD desired state
- Editing Helm values under [charts/student-app/](../charts/student-app) → triggers new deploy once committed
- Repo secret tokens are sourced from Vault using External Secrets Operator; no credentials are stored directly here

---

