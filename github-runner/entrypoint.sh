#!/usr/bin/env bash
set -e

if [ -z "$REPO_URL" ]; then
  echo "REPO_URL is not set. Example: https://github.com/your-user/your-repo"
  exit 1
fi

if [ -z "$RUNNER_TOKEN" ]; then
  echo "RUNNER_TOKEN is not set. You must pass a valid GitHub runner token."
  exit 1
fi

cd /runner

if [ ! -f .runner ]; then
  echo "Configuring GitHub Actions runner..."
  ./config.sh \
    --url "$REPO_URL" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --unattended \
    --replace
else
  echo "Runner already configured, skipping config."
fi

echo "Starting GitHub Actions runner..."
exec ./run.sh
