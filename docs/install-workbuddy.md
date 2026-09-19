# 装到 WorkBuddy

## 前置条件

- 已安装 WorkBuddy；
- 拿到本仓库（`git clone` 或下载 ZIP 解压都行）。

不需要装任何依赖。`req` 是纯提示词技能，只有 `SKILL.md` 和一张图标。

## 一、选安装级别

| 级别 | 目录 | 什么时候用 |
| --- | --- | --- |
| 个人级 | `~/.workbuddy/skills/` | 所有项目都能用。**推荐**，装一次就够 |
| 项目级 | `<项目目录>/.workbuddy/skills/` | 只想在这一个项目里生效，或要跟着仓库共享给协作者 |

两处都有同名技能时，项目级优先。

## 二、放进去

### Windows（PowerShell）

```powershell
# 个人级
New-Item -ItemType Directory -Force "$env:USERPROFILE\.workbuddy\skills" | Out-Null
Copy-Item -Recurse -Force ".\skills\req-workbuddy" "$env:USERPROFILE\.workbuddy\skills\req"

# 项目级
New-Item -ItemType Directory -Force ".\.workbuddy\skills" | Out-Null
Copy-Item -Recurse -Force ".\skills\req-workbuddy" ".\.workbuddy\skills\req"
```

### macOS / Linux

```bash
mkdir -p ~/.workbuddy/skills
cp -r skills/req-workbuddy ~/.workbuddy/skills/req
```

### 放完的目录长这样

```text
~/.workbuddy/skills/req/
├── SKILL.md
└── assets/
    └── icon.svg
```

## 三、两个最容易踩的坑

**坑一：目录名必须是 `req`。**

`SKILL.md` 的 frontmatter 写的是 `name: req`，目录名要和它对上。所以是**把 `req-workbuddy` 重命名为 `req`**，
而不是原样拷进去：

```text
❌ ~/.workbuddy/skills/req-workbuddy/SKILL.md     目录名对不上
❌ ~/.workbuddy/skills/req/req-workbuddy/SKILL.md 多套了一层
✅ ~/.workbuddy/skills/req/SKILL.md
```

**坑二：不要同时装两个版本。**

`skills/req-workbuddy` 和 `skills/req-openai` 的 `name` 都是 `req`。往同一个平台里同时装两个会撞名，
行为取决于谁先被扫到。**装哪个平台就只装那一个目录。**

## 四、验证装好了

1. 新建一个会话，输入 `/skills`（或在技能选择器里翻），应该能看到 **req**；
2. 或者直接试一把：

```text
$req 我想做个记账工具
```

期望反应：Agent 先读一下当前项目、用 1—3 句话复述它对你的理解，然后**弹出一个选择题**问最关键的那个缺口——
而不是立刻开始给你写表结构。

3. 如果技能没出现：确认目录名是 `req`、`SKILL.md` 在目录正下方，然后重启 WorkBuddy。

## 五、卸载

```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\.workbuddy\skills\req"
```

```bash
rm -rf ~/.workbuddy/skills/req
```

技能是纯文本的，卸载不会留残留。

## 六、想调成自己的节奏

所有行为都在 `SKILL.md` 里，直接用编辑器改：

| 想改什么 | 改哪里 |
| --- | --- |
| 每轮问几个问题 | §3「每轮默认只问 1—3 个独立决策」 |
| 什么时候必须画图 | §6「何时画图」 |
| 图存到哪、叫什么名 | §6「展示、保存与检查」第 2 条 |
| 简报存到哪 | §9「文字简报默认保留在对话中」那一条 |
| 收口要多严 | §7 的 7 条勾选条件 |

⚠️ 这是**改行为**，不是改文档。改完请用 [`CONTRIBUTING.md`](../CONTRIBUTING.md#验收场景改完必须各跑一遍)
里的 5 个验收场景实跑一遍，别用「文件能打开」代替效果验证。

> 个人称呼（比如让 Agent 叫你"老大"）**不要写进 `SKILL.md`**——那是所有人共享的规则。
> 在对话里直接说就行。
