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
| `.gitleaks.toml` | gitleaks 配置：沿用默认规则，只排除 Trellis 的 `.trellis/.template-hashes.json`（里面是 SHA-256，会被 `generic-api-key` 误判成密钥，导致 CI 的 `baseline` 失败） |

## 接入步骤

**使用 Trellis 时（公司的项目都用）：先运行 `trellis init`，再复制本目录。** 如果根目录已经有 `AGENTS.md`，`trellis init` 会跳过它，不会写入 Trellis 的内容。`trellis init` 的命令见《公司项目脚手架规范》6.4 节（注意第一条要加 `-y`，zsh 下用数组保存参数）。

在项目根目录运行（假设 handbook 克隆在项目旁边的 `../handbook`）：

```bash
git switch -c chore/project-kit

# 0. 先运行 trellis init（命令见规范 6.4 节），它会生成 AGENTS.md 和 .gitattributes

# 1. 复制公共文件：不覆盖已有的同名文件，也不复制本 README 和 AGENTS.md
rsync -a --ignore-existing --exclude README.md --exclude AGENTS.md ../handbook/project-kit/ ./
```

**2. 把公司规则合并进 Trellis 生成的 `AGENTS.md`**，不要覆盖整个文件：

```bash
printf '\n' >> AGENTS.md
cat ../handbook/project-kit/AGENTS.md >> AGENTS.md
```

Trellis 管理 `<!-- TRELLIS:START -->` 到 `<!-- TRELLIS:END -->` 之间的内容，块外的公司规则会保留。合并之后，填写“项目简介”和“技术栈”。

**3. 合并 `.gitattributes`：** 上面的复制不会覆盖已有的 `.gitattributes`（Trellis 已经生成了带 `merge=union` 规则的版本），把本目录的内容追加进去：

```bash
printf '\n' >> .gitattributes
cat ../handbook/project-kit/.gitattributes >> .gitattributes
```

**4. 启用 Git hook，同步公司 Skill：**

```bash
git config core.hooksPath .githooks
bash scripts/sync-skills.sh
```

**5. 确认 hook 和脚本有可执行权限，按项目删减 CI，提交：**

```bash
git add -A
git update-index --chmod=+x .githooks/pre-commit .githooks/pre-push scripts/*.sh

# 按项目删减 .github/workflows/ci.yml（FastAPI、Docker、Node 的 job 各取所需），
# 并确认 Makefile 里有 ci.yml 引用的目标（例如 openapi-check、build、docker-up、smoke）
git status
git commit -m "chore: 接入团队公共基线"
git push
```

然后提交 PR。项目的 `make setup` 中要包含 `git config core.hooksPath .githooks` 和 `bash scripts/sync-skills.sh`，这样每个成员克隆后都会自动启用。

没有 `rsync` 的环境（例如 Windows 的 Git Bash），用下面的命令代替第 1 步的复制，同样不复制本 README 和 `AGENTS.md`、不覆盖已有文件：

```bash
tar -C ../handbook/project-kit --exclude=./README.md --exclude=./AGENTS.md -cf - . | tar -xf - --skip-old-files
```

不要用 `cp -R` 后再删除 `README.md`：它会先覆盖项目自己的 `README.md`，删除后项目说明就丢了。

**不使用 Trellis 时**（不推荐）：复制时不用排除 `AGENTS.md`，直接用上面的命令去掉 `--exclude AGENTS.md`，然后填写 `AGENTS.md`。

## 前提条件

- CI workflow 引用了公开仓库 `TIanle-art/ci-workflows`，私有项目可以直接调用，不需要额外设置访问权限。
- `ci-workflows` 要先发布 `v1` 标签，并且 `v1` 要包含 v1.1 的内容（`python-ci` 的 `make-targets`、`docker-smoke.yml`、`node-ci` 的 `e2e-script`、`main-guard` 的豁免标签）。`ci.yml` 里的 `make-targets`、`targets` 引用的是项目 Makefile 里的目标，要确认它们存在。

## 更新已有项目

本目录更新后不会自动同步到已有项目。需要时，对比差异后手动复制：

```bash
diff -r ../handbook/project-kit/.agents/skills .agents/skills
```
