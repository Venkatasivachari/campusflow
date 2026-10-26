#!/usr/bin/env bash
# Daily MySQL backup. Cron example (2am daily):
#   0 2 * * * /home/ubuntu/college-portal/scripts/backup.sh
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
mkdir -p backups
docker compose exec -T db mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" \
  | gzip > "backups/portal-$(date +%F).sql.gz"
find backups -name '*.sql.gz' -mtime +14 -delete
