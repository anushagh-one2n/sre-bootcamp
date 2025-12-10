#!/usr/bin/env bash
set -euo pipefail

echo "[*] Updating apt..."
apt-get update -y

echo "[*] Installing prerequisites..."
apt-get install -y ca-certificates curl gnupg lsb-release

echo "[*] Installing Docker (official script)..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

systemctl enable docker
systemctl start docker

echo "[*] Installing Docker Compose v2 plugin..."
mkdir -p /usr/local/lib/docker/cli-plugins

ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-linux-aarch64"
else
  COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64"
fi

curl -SL "$COMPOSE_URL" -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

echo "[*] Adding vagrant user to docker group..."
usermod -aG docker vagrant

echo "[*] Preparing docker-compose stack..."
cd /vagrant

if [ ! -f docker-compose.vagrant.yml ]; then
  echo "[!] docker-compose.vagrant.yml not found in /vagrant"
  exit 1
fi

if [ ! -f .env ]; then
  echo "[!] .env not found in /vagrant"
  echo "    Create a .env file with Docker Hub and app config before running vagrant up."
  exit 1
fi

echo "[*] Loading environment variables from .env..."
set -a
. .env
set +a

echo "[*] Validating .env required variables..."
REQUIRED_VARS=(
  DOCKERHUB_USERNAME
  DOCKERHUB_PASSWORD
  API_IMAGE
  APP_VERSION
  DB_NAME
  DB_USERNAME
  DB_PASSWORD
  DB_PORT
  SERVER_PORT
)

for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "[!] Required env var ${var} is not set in .env"
    exit 1
  fi
done

# Set useful defaults if optional vars missing
POSTGRES_VERSION="${POSTGRES_VERSION:-15}"
DB_CONTAINER_NAME="${DB_CONTAINER_NAME:-prod-db}"
NGINX_VERSION="${NGINX_VERSION:-alpine}"
NGINX_PORT="${NGINX_PORT:-80}"

echo "[*] Constructing DB_URL for internal Docker Compose network..."
DB_URL="jdbc:postgresql://db:${DB_PORT}/${DB_NAME}"
export DB_URL

echo "[*] Docker Hub Login..."
echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin

echo "[*] Launching Docker Compose stack..."
docker compose --env-file .env -f docker-compose.vagrant.yml up -d

echo "[*] Provisioning finished!"