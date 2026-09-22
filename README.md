<div align="center">

<img src="skills/req-workbuddy/assets/icon.svg" width="88" height="88" alt="req">

# req · 开发前需求访谈

**先把"想做什么"问清楚，再动手写代码。**

一个纯提示词的 Agent Skill：先整理、拓展用户的原始表达，再判断是否需要访谈，分轮追问目标、流程、边界与验收，产出可直接进入开发计划的需求简报，
并为新项目或复杂开发交付需求思维导图与功能架构图。

[![License](https://img.shields.io/badge/License-MIT-4F46E5.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/平台-WorkBuddy%20%7C%20OpenAI%20Codex-10B981.svg?style=flat-square)](#安装)
[![Prompt only](https://img.shields.io/badge/依赖-无脚本%20%7C%20无依赖-6B7280.svg?style=flat-square)](#边界与安全)
[![Language](https://img.shields.io/badge/语言-简体中文-E11D48.svg?style=flat-square)](README.md)

</div>

---

## 这是什么

`req` 是一套**工作流约定**，不是一个程序。它教 Agent 在开发开始之前，用最少的轮次把需求问到"可以排计划"的程度。

它主要做以下几件事：

| 做 | 不做 |
| --- | --- |
| 提示词增强：整理目标、场景、结果与约束，标清可能理解和关键缺口，再判断是否访谈 | 不把 AI 补充的内容当作已确认需求，不强行扩写明确的小修改 |
| 只读调查：读 `AGENTS.md`、`README`、目录结构、相关代码 | 不写业务代码、不搭脚手架、不装依赖 |
| 分轮追问：每轮只问 1—3 个真正影响后续的决策 | 不发固定问卷、不自问自答、不把沉默当同意 |
| 交付：需求简报 + 需求思维导图 + 功能架构图 | 不做任务拆分、不做测试、不做代码审查 |

它的价值在于**拦住返工**。需求阶段一个没问清的选择，到编码阶段往往要用几倍的改动来偿还。

## 为什么需要它

普通对话里最容易发生的三件事，恰好是它专门针对的：

- **跳步**——用户说"帮我做个记账工具"，Agent 直接开始写表结构。`req` 会先问清"谁在什么场景下记账、第一版只做哪件事"。
- **问卷轰炸**——一次性甩出 20 个问题，用户看完就跑了。`req` 每轮只问 1—3 个，先问会改变后续问题的那个。
- **假装确认**——把"你看着办"当成授权。`req` 明确规定：含糊不是授权，代付费、公开数据、永久删除这类缺口保持阻塞。

## 仓库结构

```text
.
├── skills/
│   ├── req-workbuddy/          ← WorkBuddy 安装版
│   │   ├── SKILL.md            全部行为规则（含原生选择弹窗提问约定）
│   │   └── assets/icon.svg
│   └── req-openai/             ← OpenAI Codex / ChatGPT Skills 安装版
│       ├── SKILL.md            同一套规则，提问方式改为「优先用宿主原生提问工具」
│       ├── agents/openai.yaml  显示名称、启动提示、隐式调用开关
│       └── assets/icon.svg
├── docs/
│   ├── install-workbuddy.md    装到 WorkBuddy 的完整步骤
│   ├── install-codex.md        装到 Codex / ChatGPT 的完整步骤
│   └── design-notes.md         双版本差异与设计取舍
├── examples/
│   └── session-walkthrough.md  一场典型访谈长什么样
├── scripts/
│   └── check-skill.sh          零依赖完整性校验（维护者用，不参与技能运行）
├── .github/                    议题与 PR 模板 + CI
├── CHANGELOG.md
├── CONTRIBUTING.md
└── LICENSE
```

两个版本使用**相同的称呼、访谈和图示规则**，只有平台措辞不同；`SKILL.md` 单独使用也能工作，不依赖其他绘图技能。
**按你要用的平台挑一个目录安装即可，不要两个都装进同一个平台**（`name` 都是 `req`，同时安装会撞名）。

## 安装

### 装到 WorkBuddy

个人级目录 `~/.workbuddy/skills/`（所有项目复用），或项目级目录 `.workbuddy/skills/`。

```text
~/.workbuddy/skills/req/SKILL.md
~/.workbuddy/skills/req/assets/icon.svg
```

把 `skills/req-workbuddy` 整个目录**重命名为 `req`** 放进去，不要多套一层同名目录。

```bash
mkdir -p ~/.workbuddy/skills
cp -r skills/req-workbuddy ~/.workbuddy/skills/req
```

### 装到 OpenAI Codex / ChatGPT Skills

个人级目录 `$HOME/.agents/skills`，或项目级目录 `.agents/skills`。

```text
~/.agents/skills/req/SKILL.md
~/.agents/skills/req/agents/openai.yaml
~/.agents/skills/req/assets/icon.svg
```

把 `skills/req-openai` **重命名为 `req`** 放进去。目录不存在时先执行 `mkdir -p "$HOME/.agents/skills"`。

```bash
mkdir -p "$HOME/.agents/skills"
cp -r skills/req-openai "$HOME/.agents/skills/req"
```

Codex 会自动发现技能变化，列表没更新就重启。

> 详细步骤、目录权限与常见报错见 [`docs/install-workbuddy.md`](docs/install-workbuddy.md) 和 [`docs/install-codex.md`](docs/install-codex.md)。

## 怎么调用

显式点名最稳：

```text
$req 我想开发一个【描述你的想法】。
先在保留原意的基础上整理并增强我的表达，再判断需要澄清哪些内容，每轮只问 1—3 个关键问题。
新项目或复杂开发请展示需求思维导图和功能架构图，并在模式允许时保存两份 SVG。
需求确认后再进入开发计划，先不要写代码。
```

WorkBuddy 下技能选择器里叫 **req**；Codex 下可在技能选择器中选中 **开发前需求访谈**，CLI 用 `$req`，或 `/skills` 查找。
也可以在 `/skills` 里按描述隐式匹配（`allow_implicit_invocation: true`），但显式调用更可靠。

### 想每次都先问清楚

把下面这段并进 `AGENTS.md`（WorkBuddy 的全局规则 / Codex 的 `~/.codex/AGENTS.md`），**不要贴全文**：

```markdown
## 开发前需求澄清
新程序、新功能或重大修改涉及未明确的目标、流程、范围或验收时，先读取并遵循已安装的 req 技能，再形成开发计划；需求未确认前不实施。
明确的小修改、普通问答和已确认方案不重复完整访谈。技能不可用时说明情况，仍先澄清关键缺口，不假装已调用。
```

## 它怎么工作

先增强用户表达，再判断是否需要访谈；需要访谈时，按以下骨架推进：

| 节 | 做什么 |
| --- | --- |
| §1 先增强提示词，再判断范围 | 保留原意，整理目标、场景、结果和约束，标清 AI 可能理解与关键缺口，再判断是否访谈；明确的小修改简短整理后跳过完整访谈 |
| §2 先理解再提问 | 先只读调查，维护决策记录（用户已确认／证据已核实／AI 建议／待决定／暂不做） |
| §3 分轮追问 | 每轮 1—3 题，问题落到具体场景，先问会改变后续问题的那个 |
| §4 查漏视角 | 8 个视角查缺口，优先找"答错会返工"的，不纠结配色 |
| §5 谁来决定 | 目标、范围、权限、费用归用户；能查证的事实和技术细节归 AI |
| §6 需求可视化 | 思维导图 + 功能架构图，标清"待确认"与"AI 建议" |
| §7 收口标准 | 7 条可检查的条件，不用虚构的"需求成熟度 95%" |
| §8 需求简报 | 按模板输出，集中确认一次 |
| §9 交接与退出 | 标记"可进入计划"，把后续还给原生流程 |

## 默认称呼与图示交付

- 对话默认使用"你"或省略称呼；用户明确指定称呼时遵从，**不继承技能作者的个人称呼习惯**。
- 新项目、新独立功能的初期需求梳理，以及涉及多模块、多角色、跨系统协作或复杂数据流的开发，默认提供需求思维导图与功能架构图。明确的小修改不强制画图；已有需求不重复完整访谈，用户要求不画图时遵从。
- 思维导图梳理目标、用户、流程、范围与约束；架构图**只展示模块与数据流，不提前锁定技术方案**。建议和待确认内容直接标在图中。
- 掌握目标和核心流程后展示初稿，最终简报附两张最新图。对话优先渲染 Mermaid，同时在当前模式及工具权限允许时保存两份独立 SVG；需求变化时同步更新。
- 图文件优先遵循用户指定位置和宿主交付目录规则；都未指定时使用项目的 `docs/requirements/`。文件名为 `<项目名>-需求思维导图.svg` 和 `<项目名>-功能架构图.svg`。
- 宿主不支持 Mermaid 时预览 SVG，不能内嵌时提供文件打开入口。模式禁止写入或写入失败时说明"SVG 未保存"并交接待办；**无法渲染时明确图示待展示，不能把源代码当成已展示的图**。

## 改自己的偏好

全部行为都在 `SKILL.md`。想调节奏就改「每轮默认只问 1—3 个决策」；个人称呼可在当前对话中提出，不必写进共享技能。图示的触发、展示和保存规则见第 6 节。

改完在**两个平台各跑一遍验收场景**，别用「文件格式正常」代替实际效果验证。

## 边界与安全

这是工作流约定，不是强制拦截器。

- 仅在当前模式及工具权限允许时输出需求文档和图文件，**不修改业务代码、不安装依赖、不运行会改变业务或环境状态的命令**。
- 不会自动切换计划模式，也不接管实现、测试、代码审查。
- **需求确认 ≠ 开发计划确认，更不等于授权执行有风险的操作。**
- 不索取密码、密钥或真实敏感数据，用脱敏样例讨论字段和流程。
- 技能本体是纯提示词实现：**无脚本、无依赖、无网络请求**，`SKILL.md` 可直接通读审计。仓库另带一个零依赖的校验脚本 `scripts/check-skill.sh`，只供维护者本地与 CI 使用，**不参与技能运行**。

## 贡献

欢迎提 Issue 和 PR。这个仓库里 **`SKILL.md` 不是散文，是代码**——改一个词就可能改变 Agent 行为，所以任何措辞改动都需要附上改动前后的实测对比。细则见 [`CONTRIBUTING.md`](CONTRIBUTING.md)。

改完先在本地跑一遍校验（CI 会跑同一份脚本）：

```bash
bash scripts/check-skill.sh
```

## 更新记录

见 [`CHANGELOG.md`](CHANGELOG.md)。

## 致谢

仓库结构与工程规范参考了生态里两个高星仓库的做法：
[`anthropics/skills`](https://github.com/anthropics/skills)（技能目录与 `SKILL.md` frontmatter 规范）
与 [`obra/superpowers`](https://github.com/obra/superpowers)（议题／PR 模板与"行为改动需评估证据"的要求）。

## 许可证

[MIT](LICENSE) © 2026 CunZhang (Cunzhang0703)
