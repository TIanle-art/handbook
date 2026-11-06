# handbook

团队协作规范、文档模板和项目公共基线。所有项目都以这里的内容为准。

## 目录

| 位置 | 内容 |
|---|---|
| [`docs/团队协作开发规范.md`](docs/团队协作开发规范.md) | 流程、分工、AI 协作、Git 与 GitHub 操作、审查、发布、故障、交付与合规 |
| [`docs/公司项目脚手架规范.md`](docs/公司项目脚手架规范.md) | 技术选型、两套后端、三种客户端、工程基线、部署和模板维护 |
| [`templates/`](templates/) | 项目简报、业务发现、PRD、ADR、发布清单、复盘等文档模板 |
| [`project-kit/`](project-kit/) | 复制到每个项目根目录的公共文件：`AGENTS.md`、Git hook、公司 Skill、CI 调用、Issue 和 PR 模板 |
| [`deploy/`](deploy/) | 服务器上使用的部署和备份脚本 |

## 文档模板

| 文件 | 用途 | 放到项目中的位置 |
|---|---|---|
| `templates/project-brief.md` | 项目简报 | `docs/project-brief.md` |
| `templates/discovery.md` | 业务发现记录 | `docs/discovery/<主题>.md` |
| `templates/prd.md` | 需求文档 | `docs/prd/<功能>.md` |
| `templates/adr.md` | 技术决定记录 | `docs/adr/NNN-<标题>.md` |
| `templates/ai-task-prompt.md` | 给 AI 的任务指令 | 复制到 AI 对话中使用 |
| `templates/task-handoff.md` | 任务交接 | Issue、PR 或 `.trellis/tasks` |
| `templates/release-checklist.md` | 发布清单 | `docs/releases/<版本>.md` 或 Release 说明 |
| `templates/postmortem.md` | 故障复盘 | `docs/runbooks/` 或 Issue |
| `templates/change-request.md` | 客户需求变更单 | `docs/` 或 Issue |
| `templates/weekly-report.md` | 客户周报 | 发给客户 |

## 部署脚本

`deploy/deploy.sh` 和 `deploy/backup.sh` 放在服务器的项目目录中，由技术负责人在服务器上运行，用法见《公司项目脚手架规范》13.5 和 13.6 节。

- 两个脚本都在 Linux 服务器上运行。
- `backup.sh` 默认只把备份保存在本机。必须配置 `BACKUP_UPLOAD_SCRIPT`，把备份上传到服务器以外的对象存储。
- 首次使用前，先在测试服务器演练部署、回退和恢复。

## 相关仓库

- [`spec-templates`](https://github.com/TIanle-art/spec-templates)：Trellis 团队规范模板
- [`ci-workflows`](https://github.com/TIanle-art/ci-workflows)：各项目共用的 CI workflow

## 如何修改

本仓库的改动同样走 PR：

1. 从 `main` 建分支，例如 `docs/<编号>-<描述>`。
2. 修改后提 PR，说明修改原因。
3. 规范的改动由模板负责人审查；涉及流程和角色的改动，团队讨论后再合并。
4. 合并后在团队频道通知，并更新规范开头的版本号。
