# 更新记录

本文件记录 `req` 技能的对外发布版本。格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号参考 [语义化版本](https://semver.org/lang/zh-CN/)。

## [未发布]

_暂无。_

## [1.0.0] - 2026-09-19

首次公开发布，双宿主版本一次交付。

### 新增

- **`req-workbuddy`**：WorkBuddy 安装版。第 3 节把宿主原生结构化提问工具（`AskUserQuestion`）指定为
  本技能**唯一**的提问方式；第 8 节同样用它收集范围确认。
- **`req-openai`**：OpenAI Codex / ChatGPT Skills 安装版。提问方式放宽为「优先用宿主原生提问工具，
  没有就用普通中文提问」；附带 `agents/openai.yaml` 声明显示名称、启动提示与隐式调用开关。
- 九节行为骨架：范围与边界 → 先理解再提问 → 分轮追问 → 查漏视角 → 决定权划分 → 需求可视化 →
  收口标准 → 需求简报与确认 → 交接与退出。
- 需求图示交付规则：需求思维导图 + 功能架构图，Mermaid 对话展示与独立 SVG 文件双交付，
  待确认项与 AI 建议必须显式标注，不得与已确认内容混淆。
- 需求简报模板，含「用户已确认／AI 建议／授权默认项／待决定／待验证」四类状态区分。
- 五态决策记录：用户已确认／证据已核实／AI 建议／待决定／暂不做。

### 设计取舍

- **纯提示词实现**：无脚本、无依赖、无网络请求，`SKILL.md` 可整份通读审计。
- **不使用虚构的成熟度指标**：以 7 条可检查的收口条件替代「需求成熟度 95%」这类无法验证的说法。
- **不接管后续流程**：需求确认 ≠ 开发计划确认，且不宣称已切换计划模式。

[未发布]: https://github.com/Cunzhang0703/req-interview-skill/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Cunzhang0703/req-interview-skill/releases/tag/v1.0.0
