# OpenCode Academic Workflow

**一套基于 OpenCode + Nix 的学术小组汇报全流程自动化管线。**

从脑暴散料到最终 PPTX 交付，6 个 SOP 覆盖完整的研究→呈现链路。Agent 引导式提问驱动决策，任务拆分保证每步可审。内容优先、格式兼容——队友只需交 .pptx，其余由 Agent 按统一规范生成。

---

## 能做什么

| 阶段 | 输入 | 输出 | SOP |
|------|------|------|-----|
| 1. 研究设计 | 脑暴散料 / brainstorm.txt | 结构化 `plan.md` | `SOP-brainstorm-to-plan.md` |
| 2. 问卷设计 | plan.md + 理论框架 | 问卷星可导入 `survey-wjx.txt` | `SOP-survey-design.md` |
| 3. 数据分析 | 问卷星 CSV | 描述统计 + 交叉分析 + Why 因果链 + 访谈提纲 | `SOP-data-to-interview.md` |
| 4. PPT 生成 | 队友 pptx/draft/txt | 统一 HTML 幻灯片（全组同一主题） | `SOP-ppt-production.md` |
| 5. 访谈→报告 | 访谈原始记录 | 维度分析 + 词云 + 500词摘要 + 项目报告 | `SOP-interview-to-report.md` |
| 6. HTML→PPTX | index.html | .pptx 最终交付文件 | `SOP-html-to-pptx.md` |

---

## 使用方法

### 1. 前置条件

- [Nix](https://nixos.org/download.html) 已安装（flake 支持）
- Git

### 2. 克隆并启动

```bash
git clone <your-repo-url> my-project
cd my-project/workflow

# 写入你的 API key（AnySearch 联网搜索）
echo "your-api-key-here" > anysearchkey.env

# 进入开发环境（首次会下载所有依赖）
nix develop

# 确认 opencode 可用
opencode --version
```

### 3. 从模板开始

```bash
# 阅读工作流模板
cat AGENTS.md

# 按照模板中的 ___ 占位符填写你的项目信息
# 然后开始和 opencode 对话——

# 你可以直接说：
# "我们脑暴完成了，brainstorm.txt 在根目录，帮我整理成研究计划"
```

### 4. 全流程走完

按照 `AGENTS.md` 中的 Roadmap，Agent 会逐步引导你完成：
brainstorm → plan → survey → data → interview → PPT → report → PPTX

每一步都由 SOP 驱动，Agent 用引导式提问帮你做出决策，而不是替你猜测。

---

## 技术栈

| 层级 | 组件 | 用途 |
|------|------|------|
| **环境** | [Nix flake](https://nixos.wiki/wiki/Flakes) | 可复现开发环境，锁定所有依赖版本 |
| **运行时** | Python 3.14 + Node.js 24 | 数据分析 / PPTX 生成 / 图片处理 |
| **AI Agent** | [OpenCode](https://github.com/anomalyco/opencode) | 对话式任务执行引擎 |
| **PPT 引擎** | HTML PPT Studio（内置 skill） | 36 主题 × 15 模板，演讲者视图，PNG 渲染 |
| **PPTX 引擎** | [PptxGenJS](https://github.com/gitbrent/PptxGenJS) | HTML→PPTX 一比一复刻 |
| **图表** | AntV API（内置 skill） | 柱状图 / 雷达图 / 桑基图 |
| **数据处理** | Python（标准库 + pillow + markitdown + jieba） | CSV 分析 / 词云 / PPTX 文本提取 |
| **文档转换** | Pandoc + LibreOffice | PDF 渲染 / 格式互转 |
| **联网搜索** | AnySearch API + DuckDuckGo（图片） | 研究资料 / 配图素材 |

### Nix flake 锁定的核心包

```
flake.nix → nixpkgs unstable
├── opencode          # AI Agent 主引擎
├── agent-browser     # 浏览器自动化 skill
├── python314         # 数据分析 / 词云 / markitdown
├── nodejs_24         # PptxGenJS / sharp / React Icons
├── google-chrome     # agent-browser 运行时
├── pandoc            # 文档格式转换
├── libreoffice       # PDF/PPTX 渲染
├── poppler-utils     # PDF→图片
├── python314Packages: pillow, markitdown, ddgs, jieba, wordcloud, python-docx, defusedxml, requests
```

---

## 操作系统支持

| 平台 | 支持级别 | 说明 |
|------|:------:|------|
| **NixOS** | 顶级公民 | `nix develop` 直接可用，零污染 |
| **其他 Linux 发行版** | 一等公民 | 安装 Nix 后 `nix develop`，不污染系统包管理器 |
| **macOS** (Intel / Apple Silicon) | 一等公民 | Nix 原生支持，flake `eachDefaultSystem` 覆盖所有 Mac 架构 |
| **Windows** | WSL2 推荐 | 原生不支持，通过 WSL2 + Nix 获得完全一致的 Linux 环境 |

**原理**：Nix flake 的 `eachDefaultSystem` 自动覆盖 `x86_64-linux`、`aarch64-linux`、`x86_64-darwin`、`aarch64-darwin`。所有依赖锁定在 `/nix/store/` 下，不污染系统，不依赖系统级 `pip` / `npm` / `apt`。项目内每个文件都以项目根为基准使用相对路径，不写死 `/home/xxx`。

Windows 用户可以：
1. 安装 WSL2 (Ubuntu 24.04)
2. 在 WSL 中安装 Nix
3. `git clone` → `nix develop` → 开搞

---

## 核心设计原则

详见 [`principles.md`](./principles.md)

1. **引导式提问** — Agent 不给开放式超纲问题，给选择题或填空提示
2. **任务拆分** — 每一步都有明确的输入、输出、自检清单
3. **内容优先** — 队友交什么格式都行（pptx/txt/口语稿），先提取内容再统一
4. **格式兼容** — pptx 只用于输入（markitdown 提取），输出统一为 HTML，最后一步转 PPTX
5. **无许可不装全局包** — 所有依赖由 flake.nix 锁定，不在用户系统上 `pip install` 或 `npm install -g`

---

## 文件结构

```
workflow/
├── README.md              # 本文件
├── AGENTS.md              # 填空式模板 — 你的项目从这里开始
├── principles.md          # 设计原则与 Agent 行为规范
├── flake.nix              # Nix 可复现环境（完整依赖树）
├── package.json           # Node.js 依赖（pptxgenjs, react, sharp）
├── anysearchkey.env       # ← 你需要创建：写入 AnySearch API Key
├── docs/                  # 6 个 SOP 操作手册（Agent 层指令）
│   ├── SOP-brainstorm-to-plan.md
│   ├── SOP-survey-design.md
│   ├── SOP-data-to-interview.md
│   ├── SOP-ppt-production.md
│   ├── SOP-interview-to-report.md
│   └── SOP-html-to-pptx.md
├── .agents/               # Skill 锁定版本
│   └── skills-lock.json
└── .gitignore             # 建议忽略 anysearchkey.env / node_modules / .opencode/
```

---

## 快速上手：从零到完整汇报

```bash
# Step 0: 写 brainstorm.txt
echo "我们选题：College Life..." > ../brainstorm.txt

# Step 1: 打开 opencode，Agent 引导式提问
opencode

# 你说：
# "这是我们的 brainstorm，帮我整理成研究计划 plan.md"
# "帮我根据 plan.md 设计一份问卷星问卷"
# "问卷数据回来了，帮我分析 CSV"
# "队友交了 pptx，帮我统一做成 HTML 幻灯片"
# "访谈做完了，帮我生成词云和 500 词摘要"
# "帮我生成最终 PPTX"

# 每一步 Agent 都会按 SOP 执行，自检清单逐项验收
# 你只需要做决策，Agent 负责执行和审计
```

---

## 真实案例产出

本 workflow 从一个真实的 PBL 项目提取——研究问题：

> **Why couldn't students reach their expectations of college life on campus?**

最终产出：
- 81 份问卷 + 2 人访谈
- 5 维理论框架（Academic / Career / Social / Autonomy / Growth）
- 30 张统一 HTML 幻灯片（5 个 Part × 全组协作）
- 500 词英文学术摘要 + 项目报告
- 词云 + 4 张数据图表
- 最终 .pptx 交付文件

详见项目根目录 `plan.md` / `analysis/` / `works/`
