#!/usr/bin/env bash
# CI 使用：确认各 Agent 目录中的公司 Skill 与 .agents/skills 一致
set -euo pipefail
targets=(".claude/skills")
shopt -s nullglob
status=0
for target in "${targets[@]}"; do
  for skill in .agents/skills/team-*; do
    name="$(basename "$skill")"
    diff -r "$skill" "$target/$name" || status=1
  done
  for copy in "$target"/team-*; do
    if [ ! -d ".agents/skills/$(basename "$copy")" ]; then
      echo "多余的副本：$copy"
      status=1
    fi
  done
done
if [ "$status" -ne 0 ]; then
  echo "公司 Skill 不一致，请运行 scripts/sync-skills.sh 后提交。"
fi
exit "$status"
