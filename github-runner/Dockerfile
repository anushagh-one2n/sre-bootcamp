FROM --platform=linux/amd64 ubuntu:20.04


# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies: curl, git, docker CLI, make, Java 21
RUN apt-get update && \
    apt-get install -y \
        curl git ca-certificates \
        make \
        docker.io \
        openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Create runner directory
WORKDIR /runner

# Download GitHub Actions runner (version pinned for stability)
# You can update RUNNER_VERSION over time as needed.
ENV RUNNER_VERSION=2.329.0
RUN curl -L -o actions-runner.tar.gz \
      https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner.tar.gz \
    && rm actions-runner.tar.gz

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default environment variables (override via docker-compose)
ENV RUNNER_NAME=docker-runner \
    RUNNER_LABELS=self-hosted \
    REPO_URL="" \
    RUNNER_TOKEN=""

ENTRYPOINT ["/entrypoint.sh"]
