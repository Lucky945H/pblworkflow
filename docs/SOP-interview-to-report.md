# SOP：访谈 → 分析 → 摘要 → 项目报告

**触发条件**：访谈已执行（`interviews/rawinterview*.txt` 有原始文本），需要从散乱的访谈记录提炼分析、生成视觉辅助、写 500 词摘要和项目报告。

**目标**：把口头回答变成结构化分析 → 词云 → 英文学术摘要 → 可按模板提交的项目报告。

---

## 一、输入：Agent 必须先读什么

| 文件 | 读它干什么 |
|------|-----------|
| `interviews/rawinterview*.txt` | 原始访谈文本 — 格式通常不规整（含标签 A1./B2./F5. 等和闲聊碎片） |
| `plan.md` | 理论框架维度清单、整体报告结构、15min 管线 — 分析必须对齐框架 |
| `content-guidelines.md` | 内容红线 — 约束分析输出什么不该出现在摘要里 |
| `works/` 各 Part 的 `script.md` / `ppt-outline.md` | 汇报实际内容 — 摘要和项目报告的结论必须与汇报一致 |
| `analysis/` | 已有量化分析 — 访谈分析必须与量化发现互相印证/对照 |

---

## 二、Agent 工作流

### 阶段 0：验收原始文本

`rawinterview*.txt` 的典型形式：
- 多段对话，用 `A1.`/`B2.`/`F5.` 等标签分块
- 可能混有中英文碎片、表情符号、口语化表述
- 可能包含多人在同一个文件里

**验收清单：**
```
□ 能辨识出几个受访者？（检查 "interviee 1" / "interview 1" 等标记）
□ 每个受访者的基本信息可提取吗？（年级、专业）
□ 标签（A、B、F、H 等）是否对应访谈提纲的模块？
□ 有没有缺标签的游离回答？
□ 有没有看起来明显是受访者 A 但标错标签的情况？
```

**本次 session 样本**：
- 2 个受访者写在一个文件里，标签 A/B/F/H 对应不同访谈模块
- S1 标签系统较为完整（A 期望/gap、B 自管、F 情感反应、H 关系）
- S2 只有 A 标签（较短的访谈）

---

### 阶段 1：解析 → 维度主题映射

#### 步骤 1：把每个回答归类到 5 个理论维度

直接在原文本上打 tag，不丢失原文：

```
读每一段回答 → 判断它涉及的维度（可跨多维度）→ 记录下来
```

**映射规则**：

| 谈论内容 | 归入维度 | 示例 |
|----------|---------|------|
| 课程难度、教学方式、学习体验 | Academic Adaptation | "算法集训找不到队友又被工科数学分析爆杀" |
| 实习、职业方向、成为大神 | Career Development | "成为大神"、"结识未来的伙伴" |
| 朋友、社交圈、恋爱、小组合作 | Social & Emotional | "希望能碰到很多很多有趣多才多艺的大佬带我飞" |
| 作息、时间管理、自控力、消费 | Autonomy & Self-management | "可以自由安排，但是自由安排的东西也多了" |
| 兴趣、健身、健康、新技能 | Personal Growth & Well-being | "想要空出时间学新技能还是太难了" |

#### 步骤 2：为每个维度写 Why 线索

每个维度下回答的不只是"有 gap"，还要提取**为什么有**。格式：

```
维度名
  Why 线索 1：一句话 ← 证据（S1 A1: "xxx"）
  Why 线索 2：一句话 ← 证据（S2 A3: "xxx"）
```

#### 步骤 3：提取跨维度共性模式

寻找两个或多个维度共有的底层逻辑。本次 session 3 个核心模式的例子：

```
链 1：自由悖论 → 自主管理 + 个人成长
链 2：社交角色倒挂 → 社交情感
链 3：信息源扭曲期望 → 全维度
```

---

### 阶段 2：生成词云

#### 步骤 1：提取中文文本、分词

```python
all_chinese = ''.join(re.findall(r'[\u4e00-\u9fff\u3400-\u4dbf]+', text))
words = jieba.cut(all_chinese)
```

#### 步骤 2：设置停用词表

除常见停用词外，必须手动加访谈特化停用词：

```python
# 常见停用词 + 访谈上下文特化（如 "知道" "以及" "一方面" 等高频无意义词）
# 以及表示不确定性的口语词（如 "可能" "也许" "感觉" 等，看情况）
```

#### 步骤 3：找中文字体

**警告：Pillow 的 wordcloud 渲染中文需要从 nix store 找字体路径，不能硬编码。**

```bash
# 先从 fc-list 或 nix store 找到可用的中文字体
python3 -c "
from PIL import ImageFont
for f in glob.glob('/nix/store/*/share/fonts/truetype/*.ttc'):
    try:
        ft = ImageFont.truetype(f, 12)
        print(f'OK: {f}')  # 找到第一个可用的就 break
    except: pass
"
```

#### 步骤 4：生成并保存

```python
wc = WordCloud(
    font_path='/path/to/wqy-microhei.ttc',  # 从步骤 3 获取
    width=1200, height=600,
    background_color='white',
    max_words=100,
    collocations=False,
    prefer_horizontal=0.75,
    colormap='viridis',
).generate_from_frequencies(dict(counter))
wc.to_file('interviews/assets/wordcloud.png')
```

#### 步骤 5：评估词云质量

```
□ 高频词是否扣住了访谈的核心叙事？（"时间""自由""学习""队友" 等）
□ 有没有过度被停用词污染？
□ n<5 的访谈样本：词云厚度必然有限——标注 "n=2, indicative only"
```

---

### 阶段 3：提取可引用金句

从原始文本中挑选 5-10 句原文，准备英译。挑选标准：

1. **浓缩度高**："睡个好觉！"——4 个字讲完整个自主管理困境
2. **有反讽/张力**："你要知道可以自由支配时间的杀伤力"——自由=杀伤力
3. **情感浓度高**："我的高要求反而让我不是水货"——骄傲+心酸
4. **金句模式**：短句、对仗、意外的形容词搭配

输出一张中英对照表：

| 受访者 | 场景 | 中文 | English |
|--------|------|------|---------|
| S1 A2 | 小组合作 | 我的高要求反而让我不是水货 | "My high standards turned out to be what kept me from being a slacker." |
| ... | ... | ... | ... |

**翻译原则**：
- 不是字面翻译，是要在英文中重建原句的情绪和冲击力
- 短句保持短句，长句可适当断句
- 口语化保留口语化（"totally destroyed" 而不是 "experienced significant difficulty"）

---

### 阶段 4：写 500 词英文学术摘要

摘要必须严格遵守以下结构：

```
第 1 段：研究问题 + 背景（1 句背景，1 句问题，1 句意义）
第 2 段：方法（调查 n=XX + 访谈 n=XX + 5 维理论框架）
第 3 段：核心发现（gap 排序 + 前二原因 % + 情绪反应 %）
第 4 段：访谈发现（2-3 个因果链，嵌入 1 句语录）
第 5 段：正向补充（哪方面达到了？靠什么？）
第 6 段：结论（3 层因果链 + 建议）
第 7 段：Keywords
```

**硬约束**：
- 500±50 词（用 `wc -w` 验证）
- 全一线数据（n=81, 79% freshmen, Time Autonomy +1.27, 58.0% 等）必须和 `analysis/` 一致
- 理论框架维度名必须和 `plan.md` 一致
- 引语必须来自金句表，标注为直接引用（双引号）
- 不用"we believe"、"we think" → 用"we found"、"the data suggest"
- 不用"very"、"extremely" → 用具体数字代替

---

### 阶段 5：写项目报告（按模板）

**模板结构不可跳、不可改顺序**：

```
Basic Information (Title, Members, Student Numbers, Date)
1. Introduction (背景、重要性、目标、研究问题)
2. Methodology (类型、工具、参与者、数据收集、局限)
3. Project Process (时间线、任务分配、挑战与协作 → 用表格)
4. Findings / Results (关键数据 + 图表说明 + 分析 + 引语)
5. Conclusion (主要结论、目标是否达成、反思)
6. Recommendations (可选：4 条具体建议)
7. References (可选)
```

**写作规则**：
- 全组视角（"We" 作为主语，不是 "The group" 或被动语态）
- 每段一行、不展开（这不是论文正文，是报告概要）
- Findings 必须在 5-8 行内讲完 gap 排名 + 原因 + 访谈模式 + 1 句引语 + 正向补充
- Process 用表格（比段落更可读）
- 正文严格 ~500 词

**与摘要的区别**：

| | 摘要 | 项目报告 |
|------|------|---------|
| 受众 | 学术读者 | 教师（评估过程） |
| 用途 | 报告前的浓缩概要 | 提交的完整说明 |
| 方法 | 1 段 | 含表格 |
| 过程 | 无 | 含 |
| 团队分工 | 无 | 含 |
| 建议 | 3 行 | 4 条展开 |
| 视角 | 第三人学术 | "We" 视角 |

---

## 三、真实案例：本次 session 的全流程

### 输入
- `interviews/rawinterview1.txt`（2 个受访者混在一个文件，标签格式不规整）

### Agent 做了什么

**Step 1 — 解析**：
- 识别出 S1（长版，A/B/F/H 标签）和 S2（短版，仅 A）
- 每个回答手动打标签归入 5 维 + 提取 Why 线索

**Step 2 — 主题分析**：
- 对 5 个维度逐一写 Why 线索 + 证据引用
- 提取 3 条跨维度因果链（自由悖论、社交倒挂、信息源扭曲）
- 输出 `interviews/analysis-r1.md`

**Step 3 — 词云**：
- 用 jieba 分词、构建停用词表、找到 nix-store 中文字体路径、生成 1200×600 PNG
- 输出 `interviews/assets/wordcloud.png`

**Step 4 — 金句提取**：
- 挑选 8 句原文，中英对照翻译
- 翻译保留口语化冲击力（"爆杀" → "got absolutely destroyed"）

**Step 5 — 摘要**：
- 严格 510 词，7 段结构
- 所有数据精确对齐 `analysis/raw_stats.txt`

**Step 6 — 项目报告**：
- 按教师提供的模板 6 section 结构，539 词
- Process 用表格，Findings 含 gap 排名表 + 访谈发现，Conclusion 含 3 层因果链 + 反思

---

## 四、SOP 自检清单（Agent 在输出最终文件前自问）

```
□ rawinterview 文本是否被完整解析过？（没有跳过任何一段回答）
□ 每个回答是否至少归入了一个理论维度？
□ 是否找到了至少 2 个跨维度共性模式（因果链），而不只是按维度罗列？
□ 词云的停用词表是否去除了一方面/另一方面/以及/知道等访谈高频无意义词？
□ 词云生成前是否验证了字体路径可用？（不能硬编码）
□ 金句翻译是否保持了原文的口语冲击力？
□ 摘要的每一个数字是否在 analysis/ 中有依据？
□ 摘要的 5 个理论维度名是否与 plan.md 一致？
□ 项目报告是否严格按模板的 6 section 结构？
□ 项目报告是否用 "We" 作为全程主语？
□ 摘要 + 报告的总词数是否在 ~1000（各 500）？
```

全部打勾 → 输出 `interviews/analysis-r1.md` + `interviews/assets/wordcloud.png` + `works/abstract/summary.md` + `works/abstract/project-report.md`。

---

## 五、常见翻车点与应对

### 翻车 1：词云字体路径不对

**症状**：`OSError: cannot open resource`
**诊断**：硬编码的字体路径在 nix 环境下无效（每次 nix-store hash 不同）
**修复**：用 `PIL.ImageFont.truetype()` 做 dry-run，从 `glob.glob('/nix/store/*/share/fonts/.../*.ttc')` 中遍历找第一个能打开的（见阶段 2 步骤 3）
**不要**：用 `fc-list` 输出路径（可能是 .pcf.gz 等 Pillow 不支持的格式）

### 翻车 2：词云太稀薄

**症状**：2 个受访者生成的词云最高频只有 3 次，视觉上稀疏无力
**诊断**：访谈样本本身就是 n=2
**应对**：
- 如实生成，但在分析报告和图片 caption 中标注 "n=2, indicative only"
- 后续访谈多了再重新跑一次生成
- 不要人为降低停用词强度来撑大词云——会引入噪音

### 翻车 3：摘要数据与 analysis/ 不一致

**症状**：摘要里写 "Career gap +1.15" 但 analysis 里是 +1.12
**诊断**：凭记忆写数据
**修复**：写摘要前打开 `analysis/raw_stats.txt` 逐行确认每个数字

### 翻车 4：项目报告写成摘要的加长版

**症状**：项目报告就是把 500 词摘要的每一段拉长，内容结构完全复用
**诊断**：混淆了摘要（学术浓缩）和项目报告（过程说明 + 团队分工 + 建议展开）
**修复**：强制差异——Process 用表格、含团队分工、建议展开为 4 条具体行动，摘要没有这些

### 翻车 5：金句翻译过度学术化

**症状**："爆杀"翻成 "experienced significant academic difficulties"
**诊断**：翻译时切换到了学术写作模式
**修复**：
- 翻译访谈引语时，用手口语调："got absolutely destroyed by math analysis"
- 想象受访者面直接对英文听众说这句话，他会怎么表达——而不是论文怎么写

---

## 六、输出后 — 交接

```
interviews/
├── rawinterview1.txt         ← 原始输入（不要改）
├── analysis-r1.md            ← 维度分析 + 因果链 + 金句表
└── assets/
    └── wordcloud.png         ← 词云（可嵌入 PPT）

works/abstract/
├── summary.md                ← 500 词英文学术摘要
└── project-report.md         ← 按模板 6 section 的项目报告
```
