#!/usr/bin/env bash
# 在服务器的项目目录中运行：./deploy.sh <版本号>，例如 ./deploy.sh v1.3.0
set -euo pipefail

version="${1:?用法：./deploy.sh <版本号>}"
# FastAPI 用 "alembic upgrade head"；NestJS 用 "pnpm prisma migrate deploy"
migrate_cmd="${MIGRATE_CMD:-alembic upgrade head}"
health_url="${HEALTH_URL:-http://127.0.0.1:8000/readyz}"

previous="$(grep -E '^API_VERSION=' .env 2>/dev/null | cut -d= -f2 || true)"
echo "当前版本：${previous:-无}，目标版本：${version}"

set_version() {
  if grep -qE '^API_VERSION=' .env 2>/dev/null; then
    sed -i "s/^API_VERSION=.*/API_VERSION=$1/" .env
  else
    echo "API_VERSION=$1" >> .env
  fi
}

check_health() {
  for _ in $(seq 1 30); do
    if curl -fsS "$health_url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  return 1
}

./backup.sh
set_version "$version"
docker compose pull api
docker compose run --rm api sh -c "$migrate_cmd"
docker compose up -d api

if check_health; then
  echo "部署成功：${version}"
else
  echo "健康检查失败，回退到 ${previous:-无}" >&2
  if [ -n "$previous" ]; then
    set_version "$previous"
    docker compose up -d api
  fi
  echo "注意：数据库迁移不会自动回退，请按回滚预案处理。" >&2
  exit 1
fi
