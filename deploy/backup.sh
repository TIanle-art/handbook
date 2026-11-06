#!/usr/bin/env bash
# 在服务器的项目目录中运行：./backup.sh
# 依赖 docker-compose.yml 中名为 postgres 的服务，以及其中的 POSTGRES_USER、POSTGRES_DB 环境变量
#
# 可选环境变量：
#   BACKUP_DIR             本机备份目录，默认 /srv/backups/<项目目录名>
#   BACKUP_KEEP_DAYS       本机保留天数，默认 7
#   BACKUP_GPG_RECIPIENT   设置后用 gpg 加密备份
#   BACKUP_UPLOAD_SCRIPT   上传脚本的路径，脚本接收备份文件路径作为第一个参数，
#                          负责上传到服务器以外的对象存储
set -euo pipefail

backup_dir="${BACKUP_DIR:-/srv/backups/$(basename "$PWD")}"
keep_days="${BACKUP_KEEP_DAYS:-7}"
mkdir -p "$backup_dir"

file="$backup_dir/db-$(date +%Y%m%d-%H%M%S).sql.gz"
# 导出失败时删除不完整的备份文件
trap 'rm -f "$file"; echo "备份失败" >&2' ERR
docker compose exec -T postgres sh -c 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' | gzip > "$file"
trap - ERR

if [ "$(gzip -cd "$file" | head -c 1 | wc -c)" -eq 0 ]; then
  echo "备份失败：导出内容为空" >&2
  rm -f "$file"
  exit 1
fi

if [ -n "${BACKUP_GPG_RECIPIENT:-}" ]; then
  gpg --batch --yes --recipient "$BACKUP_GPG_RECIPIENT" --encrypt "$file"
  rm -f "$file"
  file="$file.gpg"
fi

echo "备份完成：$file"

if [ -n "${BACKUP_UPLOAD_SCRIPT:-}" ]; then
  "$BACKUP_UPLOAD_SCRIPT" "$file"
  echo "已上传到服务器以外的位置"
else
  echo "警告：没有设置 BACKUP_UPLOAD_SCRIPT，备份只保存在本机。请尽快配置上传到服务器以外的位置。" >&2
fi

find "$backup_dir" -name 'db-*.sql.gz*' -mtime +"$keep_days" -delete
