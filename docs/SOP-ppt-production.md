# SOP：研究产出 → 统一 HTML 幻灯片

**触发条件**：问卷分析完成、内容红线已定、队友提交了各自 Part 的原始材料（pptx / speech draft / outline txt），需要把全组 5 部分统一为一份视觉一致、可排练的 HTML 幻灯片。

**目标**：从任何格式的队友输入中提取内容、补全提纲、统一生成 HTML，最终合并为一份全管线可预览的 deck。

---

## 一、输入：Agent 必须先读什么

| 文件 | 读它干什么 |
|------|-----------|
| `plan.md` | 理论框架维度、汇报管线、每人分钟数 — 所有 slide 逻辑对齐此文件 |
| `content-guidelines.md` | PPT 红线：关键词+图表、不能有完整句、重心是 Why、不能逐题念问卷 |
| `analysis/raw_stats.txt` | 数据事实 — Part4/5 的数据必须从此出，不能凭空写 |
| `AGENTS.md` | 技能速查、协作工作流、合并规则、当前焦点 |
| 队友交的原始文件 | pptx / rawspeech.txt / ppt-outline.txt — 无论什么格式，内容优先 |

---

## 二、Agent 工作流

### 阶段 0：提取（格式无关、内容优先）

队友可能交 pptx、口头稿、提纲 txt——**无论什么格式，第一步都是提取成纯内容**：

```
pptx  → markitdown → 提取文字 + 图片引用
.txt  → 直接读
口语稿 → 读，标记 "ppt里考虑放的部分" vs "不确定的部分"
```

提取后回答三个问题：
```
□ 这个 Part 目前有哪些 slide？每页讲什么？
□ 缺不缺 Why 解释链？（只描述数据没归因 = 不合格）
□ 缺不缺理论对照？（Part4 的每个发现必须回到 Part2 的框架）
□ 有没有和 Part2 框架/数据矛盾的表述？
```

### 阶段 1：提炼 ppt-outline.md

**Layer 1 — 提纲层**（从队友输出 → 统一 md 提纲）：

每个 slide 写：关键词 + 图表位置，无完整句。格式：
```markdown
## Slide N.M — 标题
```
**关键词 + 图表位置，无完整句**
> [CHART-POSITION: 图表类型 — 内容描述]
```

设计原则：
- **标题**：优先用队友原文（即使是另一个语言），队长要求改动再改
- **内容**：每页只写分点第一句。详情由 speaker 口述，不写 PPT 上
- **图表**：标记 `[CHART-POSITION]`，留到 Layer 3 统一生图
- **合并 vs 拆分**：队友 pptx 常有 9 页 → 提炼为 5-6 页。3 分钟 ≈ 5-6 页

特殊标记：
- 队友 pptx 的布局意图（如左右对比、流程图）保留在提纲注释中

### 阶段 2：补全 script + QA + chart-data

**Layer 2 — 全稿层**（从提纲展开，但提纲改完稿子自动跟着走）：

**script.md** — 英文演讲文字稿，每页 ~350 词：
- 用口语，不用书面语
- 过渡句独立成段
- 核心数据和理论名加粗（给演讲者当「提示信号」不是念稿）

**qa.md** — 预判 QA + 机动词汇 + 过渡短语：
- 至少 4-5 个预判问题
- 中英对照词汇表
- 3-4 个「被问住」的转移策略

**chart-data.json** — 如有图表，结构化数据：
- 纯 JSON，key 命名一致
- 引用的数字必须能从 `analysis/raw_stats.txt` 复现

### 阶段 3：统一生成 HTML

**Layer 3 — HTML 层**（从提纲统一生成）：

#### 3a. 主题选择 — 先问队长

**不要自己决定主题。** 用 `works/test/` 生成 3-5 个候选主题 × 2 张代表性 slide（标题+图表），给队长看对比后选定。

常用学术汇报候选：`xiaohongshu-white`（纯白百搭）、`corporate-clean`（商务汇报）、`academic-paper`（论文答辩）、`news-broadcast`（新闻报告）。

选定后所有 Part 统一用一个主题。`data-themes` 列表保留 5-6 个备选供 T 键切换。

#### 3b. 字号原则 — 大教室优先

假设后排看（教室投影，不是小房间白板）：

| 元素 | 原尺寸 | 大教室尺寸 |
|------|--------|-----------|
| h1 标题 | clamp(52px, 6.4vw, 84px) | clamp(64px, 7.5vw, 100px) |
| h2 副标题 | clamp(38px, 4.4vw, 56px) | clamp(48px, 5.2vw, 68px) |
| body/card 文本 | 14-19px | 18-30px |
| 脚注 | 14px | 16px 最低 |
| 图表标签 | 随图表 | 确保后排可读 |

**宁可视觉拥挤也不要看不清。** PPT 只是 outline，大部分内容 speaker 口述，slide 上全是短关键词，大字号不会溢出。

#### 3c. 屏幕内容原则

| 该放 | 不该放 |
|------|--------|
| 关键词 + 数据 | 完整句子 |
| 图表（gap / reasons / sources） | PPT 上写 "Framework = analytical lens…" |
| 数据→理论对照行（如 "All 5 reasons → Transition Theory"） | 操作解释（如 "5 dimensions = the thread tying every part together"） |
| 过渡句（如 "For many of us — college hasn't matched"） | 元评论（如 "Not just 'what happened.' We're asking why."） |
| 队友要求的原始标题 | 自行改写标题 |

**核心判断：** 观众看 PPT + 听 speaker。PPT 上的每一个词，如果 speaker 嘴巴也会说出来，就删掉。留那些 speaker 不会逐字念但观众需要看的东西：数据、图表、维度名、理论名、关键词。

#### 3d. HTML 生成

- 模板：`presenter-mode-reveal`（演讲者视图，S 键弹 4 磁吸卡片）
- 主题：`xiaohongshu-white`（默认，匹配纯白 pptx 队友插入不突兀）
- 样式：`works/Part2/style.css` 是**全组风格基准**（Part1/3/4/5 全部 link 过去）
- 自定义 style 放在各自 Part 的 `style.css`，仅当该 Part 有特殊布局需求（如 Part4 的 `.chart-image`、`.voice-card`）

所有 HTML 引用路径从 `works/{PartN}/` 视角：
```
../../.agents/skills/html-ppt/assets/...  # 上 2 层到项目根
../Part2/style.css                         # 上 1 层到 works/
../Part4/assets/chart_gap.png              # 上 1 层到 works/
```

### 阶段 4：合并预览 — `works/all/index.html`

当多个 Part 的 HTML 完成后，生成合并 deck：

```
合并规则：
- 幻灯片顺序：Part1 → Part2 → Part3 → Part4 → Part5，严格按汇报管线
- 每个 Part 的最后一张 slide 是交接桥（flow 组件 + "→ Member X" 箭头）
- 使用同一个 <body class="tpl-presenter-mode-reveal"> + 同主题
- 每个 slide 的 data-current / data-total 精确编号，全部统一
- 支持 T 键换主题、S 键演讲者视图、← → 翻页
```

**slide 总数计算**：标题页(1) + Part1(N₁) + Part2(N₂) + Part3(N₃) + Part4(N₄) + Part5(N₅) = 总 N。每页 `data-current` / `data-total` 必须一致。

---

## 三、重要约定（多次踩坑总结）

### 不到 /tmp 写任何文件

全部写入 `works/{PartN}/assets/` 或 `works/{PartN}/.tmp/`：
- 避免每次写入触发审批打断 agent loop
- 临时 URL、token 等中间数据也放本地 `.tmp/` 目录

### 先生框架，再统一生图

- 提纲、HTML、QA 先全部落定
- 图表 PNG 在所有结构定稿后**一次性**生成到 `assets/`
- 避免反复改图触发反复审批
- 每次改完 `index.html`，重新渲染所有 PNG 覆盖 `assets/`

### PPT 是 outline，不是讲稿

- 每页最多 3-5 个关键词 + 1 张图
- 大部分内容由 speaker 口述
- `<aside class="notes">` 里写演讲者逐字稿（150-350 词），按 S 键查看

---

## 四、真实案例速查

### 输入形态 × 处理方式

| 队友交来 | 含有什么 | Agent 做什么 |
|----------|----------|-------------|
| .pptx（Part3/4） | 每页标题+图片 | markitdown 提取 → 提炼 9 页→6 页 → 补理论对照 |
| rawspeech.txt（Part1） | 口语稿，含 #PPT 标注 # | 解析标注 → 提炼 5 页 → 对齐 Part2 术语 |
| ppt-outline.txt（Part5） | 4 页简要提纲，数据有误 | 用原文标题 + 修正数据 → 扩为 5 页含 RQ+局限 |

### Part 处理时间线（本次 session）

```
Part2 基准 → Part3 pptx 提取 → Part4 pptx 提取+深补Why →
Part1 speech 提炼 → Part5 outline 补全 →
all/index.html 合并 → 主题测试 → 字号放大 → 清理 meta-text
```

---

## 五、自检清单（Agent 在合并前自问）

```
□ 所有 slide 的数据是否可以从 analysis/raw_stats.txt 复现？
□ Part4 的每个发现是否都有一个理论对照（Part2 的 3 个理论之一）？
□ Part5 的 gap 排名是否和 Part4 的图表一致？
□ Part1 的 5 维术语是否和 Part2 一字不差？
□ 每页 slide 是否已删掉演讲者才会说的解释句？
□ data-current / data-total 是否全部统一？
□ 合并 HTML 是否只有一个 <div class="deck">？
□ 图表 PNG 的路径是否正确（从 works/all/ 视角是 ../Part4/assets/...）？
□ 有没有写到 /tmp 的文件？
```
