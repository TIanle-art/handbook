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

# 1. 复制公共文件，不覆盖已有的同名文件
rsync -a --ignore-existing --exclude README.md ../handbook/project-kit/ ./
#    已有的同名文件没有复制，逐个对比后手工合并，例如 Trellis 生成的文件：
diff -u AGENTS.md ../handbook/project-kit/AGENTS.md
diff -u .gitattributes ../handbook/project-kit/.gitattributes

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

没有 `rsync` 的环境（例如 Windows 的 Git Bash），用下面的命令代替第 1 步的复制，同样不复制本 README、不覆盖已有文件：

```bash
tar -C ../handbook/project-kit --exclude=./README.md -cf - . | tar -xf - --skip-old-files
```

不要用 `cp -R` 后再删除 `README.md`：它会先覆盖项目自己的 `README.md`，删除后项目说明就丢了。

## 使用 Trellis 时

先按《公司项目脚手架规范》6.4 节运行 `trellis init`，再复制本目录的文件。无论选了哪些工具，Trellis 都会生成根目录的 `AGENTS.md` 和 `.gitattributes`，上面的复制命令不会覆盖它们，需要手工合并：

- `AGENTS.md`：保留 `<!-- TRELLIS:START -->` 到 `<!-- TRELLIS:END -->` 之间的内容，把本目录 `AGENTS.md` 的公司规则加在这个块之后。
- `.gitattributes`：保留 Trellis 的 `merge=union` 规则，追加本目录 `.gitattributes` 的内容。

## 前提条件

- CI workflow 引用了私有仓库 `TIanle-art/ci-workflows`，需要先在该仓库的 Settings → Actions → General → Access 中允许其他仓库访问。
- `ci-workflows` 要先发布 `v1` 标签。

## 更新已有项目

本目录更新后不会自动同步到已有项目。需要时，对比差异后手动复制：

```bash
diff -r ../handbook/project-kit/.agents/skills .agents/skills
```
