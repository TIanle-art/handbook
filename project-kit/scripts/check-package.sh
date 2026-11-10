#!/usr/bin/env bash
# 用法：scripts/check-package.sh <app.asar 路径>
set -euo pipefail
asar_path="$1"
pattern='^/(\.env|\.env\..*|src|tests?|docs|openspec|\.trellis|\.agents|\.claude|\.github|AGENTS\.md|CLAUDE\.md)(/|$)|\.map$|\.(pem|key|p12|pfx)$'
# 列表命令失败时直接退出，不会误判为通过；反斜杠统一换成斜杠以兼容 Windows
file_list="$(npx --yes @electron/asar list "$asar_path" | tr '\\' '/')"
found="$(printf '%s\n' "$file_list" | grep -v '^/node_modules/' | grep -E "$pattern" || true)"
if [ -n "$found" ]; then
  echo "安装包中发现不应打包的文件："
  echo "$found"
  exit 1
fi
echo "安装包检查通过"
