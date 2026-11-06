# project-kit

每个项目都要带的公共文件。新建项目或给已有项目接入规范时，把本目录的内容复制到项目根目录（不要复制这个 README）。

## 内容

| 文件 | 作用 |
|---|---|
| `AGENTS.md` | 所有 AI Agent 的主规则，复制后填写项目简介和技术栈 |
| `CLAUDE.md` | 只有一行 `@AGENTS.md`，让 Claude Code 读取同一份规则 |
| `.githooks/pre-commit` | 阻止在 `main` 上提交；安装了 gitleaks 时扫描密钥 |
| `.githooks/pre-push` | 阻止直接推送 `main` 和更新已有的 `release/*` |
| `.agents/skills/team-*` | 公司 Skill：系统化调试、完成前验证、处理审查意见 |
| `scripts/sync-skills.sh` | 把公司 Skill 复制到 `.claude/skills/` |
| `scripts/check-skills.sh` | CI 检查各目录中的公司 Skill 是否一致 |
| `scripts/check-package.sh` | 桌面项目使用：检查安装包里有没有不该打包的文件 |
| `.github/workflows/ci.yml` | 调用 `ci-workflows` 的 CI，按项目删减 |
| `.github/workflows/main-guard.yml` | 检查进入 `main` 的提交是否来自已批准的 PR |
| `.github/ISSUE_TEMPLATE/` | 功能和缺陷的 Issue 表单 |
| `.github/pull_request_template.md` | PR 模板 |
| `.editorconfig`、`.gitattributes`、`.gitignore` | 编码、换行符和忽略规则 |

## 接入步骤

在项目根目录运行（假设 handbook 克隆在项目旁边的 `../handbook`）：

```bash
git switch -c chore/project-kit

# 1. 复制公共文件；已有同名文件时先对比再决定
rsync -a --exclude README.md ../handbook/project-kit/ ./

# 2. 启用 Git hook，同步公司 Skill
git config core.hooksPath .githooks
bash scripts/sync-skills.sh

# 3. 确认 hook 和脚本有可执行权限
git add -A
git update-index --chmod=+x .githooks/pre-commit .githooks/pre-push scripts/*.sh

# 4. 填写 AGENTS.md，按项目删减 .github/workflows/ci.yml
git status
git commit -m "chore: 接入团队公共基线"
git push
```

然后提 PR。项目的 `make setup` 中要包含 `git config core.hooksPath .githooks` 和 `bash scripts/sync-skills.sh`，这样每个成员克隆后都会自动启用。

没有 `rsync` 的 Windows 环境，可以在 Git Bash 中用 `cp -R ../handbook/project-kit/. ./` 后删除复制过来的 `README.md`。

## 使用 Trellis 时

先按《公司项目脚手架规范》6.4 节运行 `trellis init`，再复制本目录的文件。Trellis 会为 Codex 生成或修改 `AGENTS.md`：复制前先对比，把公司规则合并进去，不要直接覆盖 Trellis 生成的内容。

## 前提条件

- CI workflow 引用了私有仓库 `TIanle-art/ci-workflows`，需要先在该仓库的 Settings → Actions → General → Access 中允许其他仓库访问。
- `ci-workflows` 要先发布 `v1` 标签。

## 更新已有项目

本目录更新后不会自动同步到已有项目。需要时，对比差异后手动复制：

```bash
diff -r ../handbook/project-kit/.agents/skills .agents/skills
```
