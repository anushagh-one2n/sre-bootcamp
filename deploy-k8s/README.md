## Setting up minikube cluster

- As a part of setting up a k8s cluster using minikube:
  - 3 nodes will be created, and labeled.
  - Deployments for the application and the database will be created.
  - Db credentials will be created as k8s secret(will be sourced from secrets/db.env).
- On running `./start-mini.sh`, a minikube cluster with 3 nodes will be spun up. (PS: give the file exec permissions if
  it fails to run).
- The 3 nodes are labeled as:
    - application
    - database
    - dependent_service
- You can take a list the nodes using: `kubectl get pods --show-labels`
- There will also be 2 deployments created, one each for the application and the postgres db instance.
- Two instances(pods) will be created for the application, as specified in the application manifest(specified as replicas field).

## Requirements:

- Minikube
- Kubectl
- Kubectx (for easy switching of contexts)

## Running the application on the cluster

- To successfully run the application, you will have to:
    1. Copy over the [env.example file](secrets/db.env.example) as db.env and then set the env vars appropriately.
    2. Run the setup script to [bootstrap the cluster](#setting-up-minikube-cluster).
    3. Set the image to be pulled to run the application.\
       Command to set the image:
        ```
            kubectl set image deployment/student-api-app \
            student-api=<DOCKER_REPO>:<IMAGE_TAG> -n student-api
        ```
    4. Use your docker creds to create a k8s secret(using which the image specified above can be pulled) \
       Command to create docker registry secret:
        ```shell
        kubectl create secret docker-registry dockerhub-creds \
        --docker-username=<dockerhub_username> \
        --docker-password=<dockerhub_pat or dockerhub_password> \
        --docker-email=<dockerhub_email>
        ```
    5. After completing the above steps, you can restart the application deployment so that the docker image can be
       pulled and the app can run the specified image. \
       Command to restart deployment:
       ```shell
        kubectl rollout restart deployment/student-api-app
        ```
- You can then port forward the service so that you can continue using the base url `localhost` to hit the endpoints.\
  Command to port forward the service: \
  `kubectl port-forward -n student-api svc/student-api 8080:80`
- By default, the namespace will be set to `default`. You can switch to the api namespace by `kubens student-api`.