# SOP：HTML 幻灯片 → PPTX 文件

**触发条件**：某个 Part（或全组合并）的 `index.html` 已定稿、内容已审、不需要再改 HTML 结构，需要一份 `.pptx` 交给队友做最后微调、或嵌入团队的总 PPT。

**目标**：从 `index.html` 一比一复刻出内容一致、风格统一的 `.pptx` 文件，放在该 Part 根目录下。

**前置条件**：该 Part 的 HTML 必须先完成（参照 `docs/SOP-ppt-production.md` 的 Layer 3 流程）。

---

## 一、输入：Agent 必须先读什么

| 文件 | 读它干什么 |
|------|-----------|
| `works/{PartN}/index.html` | Slide 顺序、每页组件类型、文字内容 — **唯一内容源** |
| `works/{PartN}/style.css` | 该 Part 特有的布局组件（如 Part4 的 `.ba-row`、`.dim-row`、`.sug-list`）— 翻译成 pptxgen shape |
| `works/Part2/style.css` | 全组通用布局类（`.compare`、`.map-table`、`.theory-grid`、`.flow`、`.pent-node`、`.voice-card` 等）— 每种组件对应一个 pptxgen helper 函数 |
| `works/{PartN}/assets/` | 已有的图表 PNG（chart_gap、chart_reasons 等）— 确认路径真实存在，不能凭空引用 |
| `works/all/index.html` | 如果这是全组合并版，从合并版提取全部 30 张 slide（不是各 Part 单独处理） |

**不需要读**：
- 队友的原始 `.pptx` — HTML 已经是唯一内容源
- `script.md` / `qa.md` — 演讲稿不影响 PPT 排版
- `plan.md` — 内容已在 HTML 中落定

---

## 二、Agent 工作流

### 阶段 0：通读 HTML，拆出 Slide 清单（必须先做）

打开 `index.html`，找出所有的 `<section class="slide">`。对每张 slide 记录：

```
Slide N | kicker 内容 | H1/H2 结构 | 组件列表 | 是否有图表 PNG | 脚注 mono 文案
```

组件类型从 HTML class 推断：

| HTML class | 含义 | pptxgen 中对应 |
|------------|------|---------------|
| `.kicker` | 页眉 mono 标签 | `addText`（Consolas, 11pt, text3） |
| `.h1` / `.h2` | 标题，可能含 `.accent` 分段 | `renderTitle`（带 `lines` 参数） |
| `.lede` | 副标题，灰色正文 | `addText`（Calibri, 13pt, text2） |
| `.speaker` | 头像 + 名字 + 角色 | `addSpeaker`（oval + text） |
| `.compare` | 双栏对比（左/右 + 中间符号） | `addCompare`（两列矩形 + 中间箭头） |
| `.pent-node` | 带顶部 accent 的卡片 | `addPentNode`（矩形 + 顶部色条） |
| `.pent-center` | 居中横幅（带左侧 accent） | `addPentCenter`（矩形 + 虚线边框） |
| `.map-table` | 表格式列表（header + rows） | `addMapTable`（矩形 + line 分割） |
| `.theory-card` | 带编号的理论卡片 | `addTheoryCard`（矩形 + 顶部 accent） |
| `.flow` / `.flow-step` | 步骤流程图 | `addFlow`（矩形 + 箭头） |
| `.voice-card` | 大引号卡（带左侧 accent bar） | `addVoiceCard`（矩形 + 粗 accent bar） |
| `.chart-image img` | 嵌入图表 PNG | `addImage`（路径指向 assets/） |
| `.chart-placeholder` | 占位虚线框 | `addShape`（RECTANGLE + dashed border） |
| `.deck-footer` | 底部 mono 标签 + 页码 | `addFooter`（两段 text） |
| `.callout` | 虚线分割线上方一句居中文字 | `slideCallout`（LINE dashed + text） |
| 自定义类（如 `.ba-row`） | 本 Part 特有，见 style.css | 需新增 helper |

> **核心原则**：HTML 里每个组件类都要有一个对应的 pptxgen helper。Part4 的 `.ba-row`、`.dim-row`、`.sug-list` 就是例子——先写 helper，再在 buildSlide 里调用。

### 阶段 1：写 build.js（组件映射 + 组装）

脚本放在 `works/{PartN}/.tmp/build.js`，模板结构：

```javascript
const pptxgen = require("pptxgenjs");
const path = require("path");
const ROOT = path.resolve(__dirname, "..");

// 1. 主题色常量（xiaohongshu-white）
const C = { bg: "FFFDFB", surface: "FFFFFF", surface2: "FFF1EA",
  text1: "1A1210", text2: "4F3A32", text3: "A08D85",
  accent: "FF2742", border: "E6D9D2", borderStrong: "C9B4AB" };

const FONT_SANS = "Calibri";      // PPT 内置无衬线
const FONT_DISPLAY = "Calibri";   // 标题用同一个避免缺字体
const FONT_MONO = "Consolas";     // PPT 内置等宽

const W = 10.0, H = 5.625;        // LAYOUT_16x9
const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";

// 2. Helper 函数（从已有的 build.js 复制，保证全组一致）
function addKicker(slide, text) { /* ... */ }
function renderTitle(slide, lines, opts) { /* ... */ }
function addFooter(slide, current, total, monoText) { /* ... */ }
// ... 逐一移植所有组件 helper

// 3. 每张 slide 一个 build 函数
function buildSlide1() {
  const s = pres.addSlide();
  paintBackground(s);
  addKicker(s, "part 04 · data analysis & findings");
  addH1(s, [[{ text: "Data Analysis" }], [{ text: "and Findings", accent: true }]], { y: 0.85, fontSize: 36 });
  // ...
  addFooter(s, 1, TOTAL, "expectation vs reality");
}

// 4. 构建
buildSlide1(); buildSlide2(); /* ... */ buildSlideN();
pres.writeFile({ fileName: path.join(ROOT, "PartN-XXX.pptx") }).then(f => console.log("Wrote", f));
```

**Helper 移植规则**：
- 全组的 build.js 中 helper 函数必须完全一致（签名 + 颜色 + 字号）
- 把 `works/all/.tmp/build.js` 的 helper 段作为模板，只新增该 Part 特有的 custom helper
- 不要改已有的 helper 签名（否则后续合并 all PPTX 时接口不统一）

### 阶段 2：运行构建

```bash
cd works/{PartN}/.tmp && node build.js
```

输出 `works/{PartN}/PartN-XXX.pptx`。

### 阶段 3：QA — 转为图片逐一检查

```bash
# 1. PDF
cd works/{PartN} && python3 ../../.agents/skills/pptx/scripts/office/soffice.py \
  --headless --convert-to pdf PartN-XXX.pptx

# 2. 逐张 JPEG → .tmp/preview/
mkdir -p .tmp/preview && rm -f .tmp/preview/*.jpg
pdftoppm -jpeg -r 100 PartN-XXX.pdf .tmp/preview/slide

# 3. 合成 grid（可选）
cd .tmp/preview && python3 -c "
from PIL import Image; import os
slides = sorted([f for f in os.listdir('.') if f.endswith('.jpg')])
imgs = [Image.open(s) for s in slides]
# ... 合成 cols×rows 的 grid.jpg
"
```

**⚠ 必须逐张检查的项目：**

```
□ 标题是否溢出到下一行？（尤其是 H2 的多段 accent 拼接）
□ 表格（map-table）最后一行是否被 footer 遮挡？
□ 双栏 compare 的大数字是否溢出列宽？
□ 图表 PNG 是否真正嵌入（不是占位虚线框）？
□ voice-card 长段文字是否顶到底部 border？
□ footer 的 mono tag 与页码是否碰撞？
□ pent-node 网格 4-5 个并列时是否互相挤压？
□ 中文文字是否正常渲染？（pptxgenjs 中文依赖系统字体）
□ 每页 slide 的 data-current/data-total 是否和 HTML 一致？
```

### 阶段 4：修复 + 重渲染

发现一个改一个，立即重跑 `node build.js` → `pdftoppm` → 只看改过的那张。

**不要一次改十个问题再重建，容易引入新问题。** 每修一个问题就验证一次。

---

## 三、⚠ 用视觉模型提高效率（关键提示）

**纯文本模型无法看图。** 上述 QA 阶段的所有视觉效果检查——文字溢出、重叠、碰撞、截断——纯文本模型做不到。它只能在代码层面检查坐标是否超界，**看不到实际渲染结果**。

因此：

1. **渲染阶段不做 QA 跳过。** 即使觉得自己写的代码没问题，也必须跑一次 ppmt-render，因为 LibreOffice 和 pptxgenjs 对字体宽度/换行的理解不同，代码层面看不出 bug。

2. **QA 时换用视觉模型（或启用该模型的 vision 能力）。** 把 `.tmp/preview/slide-N.jpg` 传给它逐张检查。你只需要说：

   > Look at these slides. Find: overlapping elements, text overflowing boxes, elements too close to edges, broken footers, text cut off, or layout misalignment.

3. **如果真的只能用纯文本模型**（比如你），至少做以下防御：
   - 把 slide 渲染成 grid.jpg，用 `read` 工具打开，靠文件名+网格位置判断 slide 序号和大致区域
   - 对每类组件（map-table、pent-node grid、compare columns）单独输出该组件在代码中的 y + h 终点，确保总高 < 5.625"
   - 所有 multi-line title 必须显式写 `lines: [[...], [...]]`，不靠自动换行

**但最有效的方法还是换个能看图的模型。**

---

## 四、组件映射速查表

以下是从 HTML class → pptxgen shape 的对应关系。写 build.js 时直接查表。

| HTML 结构 | pptxgen 组件 | 关键参数 |
|-----------|-------------|---------|
| `<p class="kicker">` | `addText` | mono, 11pt, text3, charSpacing: 2, y ≈ 0.3 |
| `<h1 class="h1">` / `<h2>` | `renderTitle` | Font DISPLAY, 28-36pt, 接受 `lines` 数组 |
| `<p class="lede">` | `addText` | sans, 13pt, text2, y ≈ 2.0 |
| `.speaker` (av + name + role) | `addSpeaker` | 两个 oval（叠色）+ 两段 text |
| `.compare` (两列+中间符) | `addCompare` | 两个 RECTANGLE（填充 + 可选 accent bar） |
| `.compare-col.bright` | `addCompare` | 左侧 accent 5px bar + surface2 填充 |
| `.pent-node` (5 个一排) | `addPentNode` | RECTANGLE + 顶部 6px accent bar + badge/title/sub |
| `.pent-center` (居中横幅) | `addPentCenter` | RECTANGLE + 虚线边框 + 左侧 accent |
| `.map-table` (表格式) | `addMapTable` | RECTANGLE 外框 + header bg + LINE 分行 |
| `.theory-card` (3 列) | `addTheoryCard` | RECTANGLE + 顶部 accent + num/title/by/desc |
| `.flow` (4-5 步) | `addFlow` | RECTANGLE × N + `→` text 连接 |
| `.voice-card` (大引号) | `addVoiceCard` | RECTANGLE + 左侧 8px accent bar + 居中文字 |
| `.chart-image img` (图表) | `addImage` | `path`, `sizing: { type: "contain" }` |
| `.chart-placeholder` (未出图) | `addShape` + text | RECTANGLE + dashed border + 灰色 mono italic 标签 |
| `.deck-footer` | `addFooter` | 两段 text: mono tag (左) + page num (右) |
| `.callout` (虚线分割+居中) | `slideCallout` | LINE (dashed) + 居中 italic text |

**所有颜色** 使用 xiaohongshu-white 主题常量（`C.bg`, `C.accent`, `C.text1-3`, `C.border` 等），不含 `#` 前缀。

---

## 五、常见陷阱（多次踩坑总结）

### 1. 不要用 `#` 前缀

```javascript
color: "FF2742"   // ✅ 正确
color: "#FF2742"  // ❌ 导致 pptx 文件损坏
```

### 2. 不要复用 options 对象

```javascript
// ❌ 同一个 shadow 对象传两次 → 第二次已经被 mutating
const shadow = { type: "outer", blur: 6, offset: 2, color: "000000", opacity: 0.15 };
slide.addShape(pres.shapes.RECTANGLE, { shadow, ... });
slide.addShape(pres.shapes.RECTANGLE, { shadow, ... });

// ✅ 每次调用返回新对象
const makeShadow = () => ({ type: "outer", blur: 6, offset: 2, color: "000000", opacity: 0.15 });
```

### 3. `breakLine: true` 位置必须精确

```javascript
// 标题示例：3 行
addH1(slide, [
  [{ text: "Line 1" }],                          // 此行结束 → breakLine
  [{ text: "Line 2" }],                          // 此行结束 → breakLine
  [{ text: "Line 3 ", accent: true }],           // 最后一行 → 不 break
], { y: 0.85, fontSize: 36 });
```

默认不换行——只有显式的 `lines` 数组项之间才 break。**不要在 segment 之间设 breakLine**，除非 HTML 里有 `<br>`。

### 4. LAYOUT_16x9 的坐标限制

- 最大 x + w ≤ 10.0"，最大 y + h ≤ 5.625"
- Footer 固定 y = 5.625 - 0.42 = 5.205"，h = 0.3"
- 所有内容必须在 y ≤ 5.1" 以上
- **map-table 的 rowH 总和不能超过剩余空间**

### 5. 双栏 compare 的列宽和字号

- 默认 colW = 4.0"，双列 = 8.0" + arrow 0.4" + gap 0.3" → 居中 OK
- 列内 stat 字号超过 28pt 时，数字 "1.27" 可能溢出列宽 → **减小 statSize 或增大 colW**
- 列内文本超过 15 个中文字 → 减小字号或拆行

### 6. 中文在 LibreOffice 渲染 vs. PowerPoint 打开可能不同

- pptxgenjs 写的 `.pptx` 用 LibreOffice 转 PDF 时，中文可能因缺字体被替换
- **宁可偏小不要偏大** — 中文在 MS PowerPoint 打开后通常比 LibreOffice 渲染略宽
- 最终交付前必须在 PowerPoint 里打开看一次

### 7. `addPentNode` 的 sub 文本双语过长时间

- 一行 16-20 个中文字 + 英文对照会导致 `addPentNode` 的 `sub` 区溢出
- **把双语 sub 拆成两行**：小号英文 + 大号中文（或反过来）；或者精简 sub 内容

---

## 六、目录约定

```
works/{PartN}/
├── index.html              # 源（唯一内容源）
├── style.css               # 该 Part 特有布局
├── assets/                 # 图表 PNG
├── {PartN}-XXX.pptx        # ← 构建输出
├── {PartN}-XXX.pdf         # ← QA 用 PDF
└── .tmp/
    ├── build.js            # ← 构建脚本（修改后重跑）
    └── preview/            # ← QA 用 slide-*.jpg（每次重跑先 rm）
```

**路径规则**：
- `build.js` 中 `ROOT = path.resolve(__dirname, "..")`，输出到 `ROOT/{PartN}-XXX.pptx`
- 图表路径：`path.join(ROOT, "assets", "chart_xxx.png")` 或用 `"../Part4/assets/chart_xxx.png"` 等相对路径
- **绝对不写到 `/tmp`** — 审批会打断 agent loop

---

## 七、真实案例速查（本次 session）

| Part | 输入 | 幻灯片数 | 新增组件 | 输出 |
|------|------|:------:|----------|------|
| Part3 | `index.html`（新文案，EN+CN 混合） | 8 | —（全部复用已有 helper） | `Part3-Methods.pptx` |
| Part4 | `index.html`（更新后，含 ba-row/dim-row/sug-list） | 9 | `.ba-row` `.dim-row` `.chart-placeholder` `.voice-quote-body` `.sug-list` | `Part4-Findings.pptx` |
| all | `works/all/index.html`（全组 30 张合并） | 30 | —（全部复用已有 helper） | `PBL-Full-Deck.pptx` |

**套路总结**：
1. 读 HTML → 2. 拆 slide → 3. 搬运 helper → 4. 新增该 Part 特需的 helper → 5. 写 buildSlideN → 6. 跑 → 7. render → 8. 检查 → 9. 修复 → 10. 交付
