## Setting up minikube cluster

- As a part of setting up a k8s cluster using minikube, 3 nodes will be created, and labeled.
- On running `./start-mini.sh`, a minikube cluster with 3 nodes will be spun up. (PS: give the file exec permissions if it fails to run).
- The 3 nodes are labeled as:
  - application
  - database
  - dependent_service
- You can take a list the nodes using: `kubectl get pods --show-labels`


## Requirements:

- Minikube
- Kubectl 
- Kubectx (for easy switching of contexts)
