#!/usr/bin/env bash
# 把 .agents/skills/team-* 复制到其他 Agent 的 Skill 目录
set -euo pipefail
# 实测某个 Agent 读不到 .agents/skills 时，把它的目录加进来，如 ".opencode/skills"
targets=(".claude/skills")
shopt -s nullglob
for target in "${targets[@]}"; do
  mkdir -p "$target"
  rm -rf "$target"/team-*
  for skill in .agents/skills/team-*; do
    cp -R "$skill" "$target/"
  done
done
echo "公司 Skill 已同步"
