# 装到 OpenAI Codex / ChatGPT Skills

## 前置条件

- 已安装 Codex（CLI / IDE 插件）或使用支持 Skills 的 ChatGPT 环境；
- 拿到本仓库。

同样是纯提示词技能，无依赖、无脚本。

## 一、选安装级别

| 级别 | 目录 | 什么时候用 |
| --- | --- | --- |
| 个人级 | `$HOME/.agents/skills/` | 所有项目都能用。**推荐** |
| 项目级 | `<项目目录>/.agents/skills/` | 只想在这一个项目里生效 |

## 二、放进去

### macOS / Linux

```bash
mkdir -p "$HOME/.agents/skills"
cp -r skills/req-openai "$HOME/.agents/skills/req"
```

### Windows（PowerShell）

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.agents\skills" | Out-Null
Copy-Item -Recurse -Force ".\skills\req-openai" "$env:USERPROFILE\.agents\skills\req"
```

### 放完的目录长这样

```text
~/.agents/skills/req/
├── SKILL.md
├── agents/
│   └── openai.yaml
└── assets/
    └── icon.svg
```

目录名用 `req`，和 frontmatter 里的 `name: req` 对齐。

## 三、`agents/openai.yaml` 是什么

这个文件告诉宿主"这个技能该长什么样"，内容很短：

```yaml
interface:
  display_name: "开发前需求访谈"          # 技能列表里显示的名字
  short_description: "分轮问清目标、流程、边界与验收，为新项目或复杂开发交付需求思维导图与功能架构图"
  icon_small: "./assets/icon.svg"
  brand_color: "#4F46E5"
  default_prompt: "用 $req 帮我把这个开发想法问清楚：……"   # 从技能列表点进来时自动填入的提示
policy:
  allow_implicit_invocation: true        # 允许宿主按 description 自动匹配
```

想改显示名、品牌色或默认提示，改这里；想彻底关掉自动匹配，把 `allow_implicit_invocation` 设为 `false`。

## 四、怎么调用

三种方式，从稳到松：

| 方式 | 写法 | 说明 |
| --- | --- | --- |
| 显式点名 | `$req 我想开发一个……` | **最可靠**，推荐 |
| 技能选择器 | 选中「开发前需求访谈」 | 会带上 `default_prompt` |
| 隐式匹配 | 直接说"先帮我把需求问清楚" | 依赖 `allow_implicit_invocation: true`，可能不触发 |

显式点名示例：

```text
$req 我想开发一个【描述你的想法】。
先把需求问清楚，每轮只问 1—3 个关键问题。
新项目或复杂开发请展示需求思维导图和功能架构图，并在模式允许时保存两份 SVG。
需求确认后再进入开发计划，先不要写代码。
```

## 五、让 Codex 每次都先问清楚

把下面这段并进 `~/.codex/AGENTS.md`。**只贴这一段，不要贴整份 `SKILL.md`**——技能正文由宿主按需加载，
贴全文会白占上下文：

```markdown
## 开发前需求澄清
新程序、新功能或重大修改涉及未明确的目标、流程、范围或验收时，先读取并遵循已安装的 req 技能，再形成开发计划；需求未确认前不实施。
明确的小修改、普通问答和已确认方案不重复完整访谈。技能不可用时说明情况，仍先澄清关键缺口，不假装已调用。
```

## 六、验证与排错

```text
$req 我想做个记账工具
```

期望：先整理并增强原始表达，标清可能理解和缺口，再判断是否需要访谈；接着只读调查，
用 1—3 句话展示增强理解并询问关键问题，**不**直接给技术方案或把 AI 补充当作已确认需求。

| 症状 | 处理 |
| --- | --- |
| `/skills` 里找不到 | 确认目录名是 `req`、`SKILL.md` 在目录正下方 |
| 列表没更新 | Codex 通常会自动发现变化；没更新就重启 |
| 不自动触发 | 改用 `$req` 显式点名，或检查 `allow_implicit_invocation` |
| 图标不显示 | 确认 `assets/icon.svg` 与 `openai.yaml` 里的 `icon_small` 路径一致 |
| 和另一个版本冲突 | 同一平台只装 `req-openai` 或 `req-workbuddy` 中的一个 |

## 七、和 WorkBuddy 版的区别

规则完全一样，只差四处宿主措辞（提问工具、确认工具、模式切换说法、description 写法）。
完整对照表见 [`design-notes.md`](design-notes.md)。
