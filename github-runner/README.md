## Running workflows on a self-hosted runner

Currently, the CI/CD workflows(present in [the workflows dir](../.github/workflows)) are configured to run on a
self-hosted
runner.

- You can use the `make` command: `make docker-run` to start the GitHub runner in a docker container.
- Make sure you have copied the [.env.example file](../github-runner/.env.example) over as `.env` and set the env
  variables accordingly before running the docker container.

### About the CI workflow:

- There are 2 stages in the CI workflow:
    - Lint, test, and build: Here the code is checked for any linting errors, and then the application is tested and
      built.
    - Docker publish: The docker image is built, and then pushed to a dockerhub repository.
- Before running the CI workflow, make sure you have configured the following as secrets in the GitHub repo:
    - `DOCKER_USERNAME` (dockerhub username)
    - `DOCKER_PASSWORD` (dockerhub password)
    - `DOCKER_REPO` (dockerhub repo where the images will be pushed to, and pulled from)

### About the CD workflow:

The CD workflow is meant to auto deploy changes made to the repo on every successful CI pipeline completion(i.e., on
every push to main).

This workflow:

- waits for CI completion
- reads the new image tag
- updates charts/student-app/values.yaml
- commits change to the repo
- triggers ArgoCD which deploys automatically

Apart from the github repo secrets set as a part of setting up the CI workflow:

- A github PAT should be created(with permission to repo and workflow)
- This should be configured as a secret in the github repo as `GH_PAT`