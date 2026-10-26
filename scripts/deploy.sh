#!/usr/bin/env bash
# Deploy / update the portal. Run from the project root: bash scripts/deploy.sh
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo ".env missing. Run: cp .env.example .env  and edit it first." >&2
  exit 1
fi

docker compose build
docker compose up -d
docker compose ps
echo "Portal running. Open http://<EC2-PUBLIC-IP>/"
echo "Logs: docker compose logs -f backend"
