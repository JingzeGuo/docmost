#!/bin/bash
set -euo pipefail

SHA="${1:?commit SHA is required}"

REGION="eu-north-1"
APP_DIR="/opt/docmost"
IMAGE="ghcr.io/jingzeguo/docmost:${SHA}"

mkdir -p "$APP_DIR"

# Get the Compose file from exactly the same commit being deployed
curl -fsSL \
  "https://raw.githubusercontent.com/JingzeGuo/docmost/${SHA}/docker-compose.yml" \
  -o "$APP_DIR/docker-compose.yml"

# Read secrets from Parameter Store
APP_SECRET=$(aws ssm get-parameter \
  --region "$REGION" \
  --name "/docmost/app-secret" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

DB_PASSWORD=$(aws ssm get-parameter \
  --region "$REGION" \
  --name "/docmost/db-password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

# Write runtime configuration
cat > "$APP_DIR/.env.tmp" <<EOF
DOCMOST_IMAGE=$IMAGE
APP_URL=https://docmost.click
APP_SECRET=$APP_SECRET
DB_PASSWORD=$DB_PASSWORD
EOF

chmod 600 "$APP_DIR/.env.tmp"
mv "$APP_DIR/.env.tmp" "$APP_DIR/.env"

cd "$APP_DIR"

docker compose config >/dev/null
docker compose pull docmost
docker compose up -d
docker compose ps
