## Running CI workflow on a self-hosted runner

Currently, the CI workflow(present in [the workflows dir](../.github/workflows)) is configured to run on a self-hosted
runner.

- You can use the `make` command: `make docker-run` to start the GitHub runner in a docker container.
- Make sure you have copied the [.env.example file](../github-runner/.env.example) over as `.env` and set the env variables
  accordingly before running the docker container.

### About the CI workflow:

- There are 2 stages in the CI workflow:
    - Lint, test, and build: Here the code is checked for any linting errors, and then the application is tested and
      built.
    - Docker publish: The docker image is built, and then pushed to a dockerhub repository.
- Before running the CI workflow, make sure you have configured the following as secrets in the GitHub repo:
    - `DOCKER_USERNAME` (dockerhub username)
    - `DOCKER_PASSWORD` (dockerhub password)
    - `DOCKER_REPO` (dockerhub repo where the images will be pushed to, and pulled from)