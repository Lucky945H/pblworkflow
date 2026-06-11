# 工作流设计原则

本文档定义 Agent 的行为规范、项目组织逻辑、以及多 Agent 协作方式。所有 SOP 和 AGENTS.md 均遵循此原则。

---

## 一、五大核心原则

### 原则 1：引导式提问，不做假设

**Agent 不给开放式超纲问题。** 用户找 Agent 就是因为不知道怎么做——问 "你觉得深入研究什么方向好" 是无效的。

正确做法：
- 给**选择题或带提示的填空题**
- 每个问题推动一个**具体决策**
- 一次提 3-5 个问题（太少反复来回、太多用户懵）
- 优先问「锁定选题 → 研究问题定型 → 维度补全 → 方法操作化 → 团队管线 → 内容红线」

```
✅ "你列了三个方向，最终选哪个？如选 College Life，研究问题建议定为
   'Why couldn't students...?' 这个表述：Why 型 + 群体限定 + 可操作化。同意？"

❌ "你觉得深入研究什么方向好？"
```

### 原则 2：任务拆分，步步可审

**每一步都有明确的输入、输出、自检清单。** 每个 SOP 的结尾都有自检清单——Agent 在输出前必须逐项打勾。

拆分粒度：
- 单个 SOP ≤ 7 个阶段
- 每个阶段有明确的输入/输出
- 阶段之间有依赖关系，但用户可以在任意阶段介入纠正

```
SOP 链条：
brainstorm → plan.md → survey → data → interview → PPT → report → PPTX
  ↑ 每一步都有独立的自检清单，上一步不通过对下一步是硬阻塞
```

### 原则 3：内容优先，格式兼容

**队友只交他们最熟的工具——.pptx 文件。** 不要求队友写 markdown、写 HTML、写 JSON。

三层加工模型：
```
Layer 1: 提纲提炼（pptx → ppt-outline.md）
         markitdown 提取文字 → 每页梗概 → 审计：缺 Why？缺理论对照？

Layer 2: 内容补全（提纲 → 全稿）
         ppt-outline.md → script.md + qa.md + chart-data.json

Layer 3: 统一生成（提纲 → HTML）
         ppt-outline.md + style.css → index.html → assets/*.png
```

**为什么不用 pptx 做最终格式？**
- 5 个人各自做 pptx，字体、字号、配色、排版永远不统一
- HTML 由一个 Agent 统一生成 → 视觉自动一致
- 最后一步 `SOP-html-to-pptx` 把 HTML 转为 pptx 交付

### 原则 4：无许可，不装全局包

**不在用户系统上执行 `pip install`、`npm install -g`、`apt install` 等全局安装命令。**

所有依赖由 `flake.nix` 锁定：
- Python 包 → `nixpkgs.python314Packages.*`
- Node.js 包 → `package.json` + `npm install`（在 flake `shellHook` 中自动执行）
- 系统工具 → `nixpkgs.{pandoc, libreoffice, google-chrome}`

用户唯一需要的是安装 Nix。之后 `nix develop` 一键进入完全可复现的开发环境。

### 原则 5：自治 + 透明

**Agent 可以自主执行多步操作，但每一步都留下审计痕迹。**

- 所有输出文件写入项目目录（不写 `/tmp`）
- 中间产物（分析脚本、临时 URL）放在 `.tmp/` 子目录
- 自检清单在每个 SOP 末尾 → Agent 不打勾不能输出
- 生成的图表图片直接写入 `assets/`，与产出绑定

---

## 二、AGENTS.md 的角色

`AGENTS.md` 是整个 workflow 的**总控制器**。它扮演三个角色：

1. **给 Agent 的项目上下文** — Agent 读到 AGENTS.md 就知道项目是什么、进度到哪、下一步该做什么
2. **给用户的路线图** — 用户看 Roadmap 就知道当前进度和剩余任务
3. **填空模板** — 初始版本全是 `___` 占位符，用户按提示填写自身项目信息

模板式 AGENTS.md vs 生产式 AGENTS.md：

| | 模板式（初始） | 生产式（成熟后） |
|------|------------|---------------|
| 内容 | 占位符 + 引导注释 | 具体项目信息 |
| 用途 | 引导用户填空 | 驱动 Agent 执行 |
| Roadmap | 预设标准阶段 | 项目特定阶段 + 状态 |
| 更新 | 用户手动填 | Agent 实时更新进度 |

---

## 三、SOP 的设计范式

每个 SOP 遵循统一结构：

```
# SOP：{上一步输出} → {本步输出}

## 一、输入：Agent 必须先读什么
    ← 明确的文件清单 + 为什么读

## 二、Agent 工作流
    ← 分阶段指令（每个阶段 ≤ 7 步）
    ← 每一步有输入/输出/验证方法

## 三、真实案例（本次 session）
    ← 从本项目的实际执行记录中提取
    ← 展示「翻车→诊断→修复」过程

## 四、SOP 自检清单
    ← Agent 输出前必须逐项打勾

## 五、常见翻车点与应对
    ← 诊断→修复模式

## 六、输出后 — 交接给下一个 Agent
    ← 明确下一步的入口和下一个 SOP
```

自检清单是 SOP 的**强制验收关卡**。Agent 不能跳过。

---

## 四、多 Agent 协作

当多个 Part 的 HTML 完成后，需要合并为一份全管线 deck。合并规则：

- 幻灯片顺序严格按汇报管线排列
- 每个 Part 前插入分隔 slide（part title + speaker name）
- 使用同一个模板和主题
- 支持 T 键换主题、S 键演讲者视图、← → 翻页
- `data-current` / `data-total` 统一编号

合并产物放在 `works/all/index.html`，是排练和全组预览的统一入口。

---

## 五、技能（Skills）的使用规则

- **Skill 是 SOP 的工具层**，不是替代 SOP
- 每个 Skill 对应一种特定能力（html-ppt、chart-visualization、pptx 等）
- Agent 读 SOP 决定「该做什么」→ 调用 Skill 执行「怎么做」
- Skill 版本通过 `skills-lock.json` 锁定，保证可复现

| 原则 | 说明 |
|------|------|
| SOP 决策，Skill 执行 | SOP 定义流程和规范；Skill 提供技术实现 |
| 内容优先于格式 | 先从 pptx/txt 提取内容，再选模板和主题 |
| 不到 /tmp 写文件 | 所有写入项目目录，避免审批打断 |

---

## 六、AGENTS.md 填写指南

当你拿到这份 workflow 模板，你需要按以下顺序填写 AGENTS.md 中的 `___`：

1. **项目概述** — 填写研究问题、课程约束、团队人数
2. **产出区结构** — 根据你的 Part 数量调整
3. **项目约定** — 填写理论框架维度、分工、PPT 规范
4. **汇报管线** — 填写每个 Part 的负责人和时间段
5. **Roadmap** — 开始前全部标记为 ⬜，Agent 执行后逐个改为 ✅

填写完毕后，把 `AGENTS.md` 从工作流模板目录复制/链接到项目根目录，opencode 启动后会自动读取。

**动态修改**：AGENTS.md 不是写完就不动了。随着项目推进：
- Roadmap 状态实时更新
- 「当前焦点」反映最新阻塞
- 「进度日志」记录已完成的关键里程碑
- 新增约定和踩坑经验追加到末尾

最终你的 `AGENTS.md` 会从填空模板演变为类似本项目的生产版本——详细的进度日志 + 协作工作流 + 技能速查表。
