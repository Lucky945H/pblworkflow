# 快速上手指南（Quick Start）

从零基础到跑通第一条工作流管线，本文覆盖所有隐性知识。

---

## 目录

1. [你的操作系统准备好没？](#1-你的操作系统准备好没)
2. [认识终端：你的新桌面](#2-认识终端你的新桌面)
3. [安装 Nix：一次装好所有东西](#3-安装-nix一次装好所有东西)
4. [获取项目 & 一键启动](#4-获取项目--一键启动)
5. [技术栈详解](#5-技术栈详解)
6. [自定义与扩展](#6-自定义与扩展)
7. [查找资源](#7-查找资源)
8. [常见问题](#8-常见问题)

---

## 1. 你的操作系统准备好没？

这个工作流需要 **POSIX 环境**——一类遵循同一套底层标准（文件路径、进程、网络接口等）的操作系统。简单说：**macOS、Linux 原生支持，Windows 需通过 WSL2**。

### 1.1 macOS

开了箱就能用，什么都不要装。

你已经有：
- 终端：`Command + 空格` → 输入 `Terminal` → 回车
- Shell：默认 `zsh`（macOS 10.15+）
- POSIX 环境：天生的 Unix 系统

> **推荐安装**：iTerm2（更好用的终端替代品 https://iterm2.com/），但不是必须。

### 1.2 Linux（Ubuntu / Debian / Arch / Fedora 等）

开了箱就能用，什么都不要装。

打开终端：
- **Ubuntu / Debian / 大多数桌面发行版**：`Ctrl + Alt + T`，或在应用菜单搜 `Terminal`
- 默认 Shell：`bash`

### 1.3 Windows —— 你需要 WSL2

Windows 不是 POSIX 系统。但微软提供了一个完整的 Linux 内核跑在 Windows 里——**WSL2（Windows Subsystem for Linux 2）**。

#### 什么是 WSL2？

不是虚拟机、不是双系统。它是微软官方支持的「Windows 里的 Linux」——你可以在 Windows 的文件管理器里看到 WSL 的文件，也可以从 Linux 终端里访问 Windows 的盘符。性能接近原生 Linux。

安装流程一句话：**PowerShell 管理员跑 `wsl --install` → 重启 → 等 Ubuntu 自动弹出 → 设用户名密码 → `sudo apt update`**。下面是每一步的详细说明。

#### 一步步安装 WSL2

> 以下所有步骤都在 Windows 里操作。
> 要求：Windows 10 版本 2004+（内部版本 19041+）或 Windows 11。

**Step 1：以管理员身份打开 PowerShell**

右键开始菜单 → `Windows PowerShell (管理员)` 或 `终端 (管理员)`。

在弹出的蓝色/黑色窗口里操作。

**Step 2：一行命令安装**

```powershell
wsl --install
```

这条命令会依次做三件事：
1. 启用「虚拟机平台」和「Windows Subsystem for Linux」两个 Windows 功能
2. 下载并安装 Ubuntu（默认发行版）
3. 完成后提示你 **"请求的操作成功。需要重新启动…"**

> 装的是 WSL2。如果提示下载卡在 0.0%，改用 `wsl --install --web-download`。

**Step 3：重启电脑**

**必须重启。** 不重启的话 WSL 功能没生效，后续打不开 Ubuntu。

重启方式：开始菜单 → 电源 → 重启，跟平时一样。

**Step 4：重启后 —— Ubuntu 自动弹出**

重启完回到桌面，等一两分钟，会自动弹出一个**黑色终端窗口**，标题是 `Ubuntu`。里面显示：

```
Installing, this may take a few minutes...
Please create a default UNIX user account...
```

这就是 Ubuntu 在初始化了——等它解压完（就第一次慢，后面秒开）。

> **如果没自动弹出？** 偶尔 Windows 没触发自动启动，手动来：
>
> ```powershell
> # 在 PowerShell 里先看看装了哪些发行版
> wsl --list --online
> # 输出类似：Ubuntu / Debian / openSUSE / ...
>
> # 手动安装 Ubuntu（-d 指定发行版）
> wsl --install -d Ubuntu
>
> # 装完后手动启动
> wsl
> ```
>
> `wsl` 命令会启动默认发行版并进入初始化流程。如果提示已安装但未初始化，加 `-d Ubuntu` 指定。

**Step 5：创建 Linux 用户名和密码**

按提示输入：
- `Enter new UNIX username:` → 随便起，比如 `yourname`（可以跟 Windows 不同，小写英文）
- `New password:` → 设密码（输入时不显示，正常的）
- `Retype new password:` → 再输一次

之后出现 `yourname@DESKTOP:~$` 就是进去了。

**Step 6：更新包列表**

在 Ubuntu 终端里粘贴：

```bash
sudo apt update && sudo apt upgrade -y
```

首次 `sudo` 会要你输入刚才的密码。等它跑完（几分钟）。

**完成。** 你的 Windows 现在有一个完整的 Linux 子系统了。

> **以后怎么打开 WSL？** 开始菜单搜 `Ubuntu` 点开，或者 PowerShell 里输 `wsl` 直接进。

---

## 2. 认识终端：你的新桌面

### 2.1 概念区分：终端模拟器 vs Shell

Windows 用户常把「那个黑色窗口」叫 CMD 或命令行。但在 POSIX 世界，有两层东西：

| 概念 | 类比 Windows | 它干什么 |
|------|-------------|----------|
| **终端模拟器**（Terminal Emulator） | `cmd.exe` 或 `PowerShell` 窗口本身 | 一个画框框的程序，显示文字、接收键盘 |
| **Shell** | `cmd.exe` 的语言 / `PowerShell` 的语言 | 解释你输入的命令，跟系统打交道 |

常见的终端模拟器：Windows Terminal、iTerm2、GNOME Terminal、Konsole。
常见的 Shell：`bash`（最普遍）、`zsh`（macOS 默认）、`fish`（新潮）。

**一句话：终端模拟器是画框，Shell 是说话的人。你打开终端，它默认启动一个 Shell 给你用。**

### 2.2 Shell 基本操作 —— 像 Explorer 一样理解文件

把 Shell 想象成一个**纯键盘操作的 Explorer**：

| 你想做的事 | Windows Explorer | Shell 命令 |
|-----------|-----------------|------------|
| 看当前文件夹有什么 | 双击打开文件夹，看图标 | `ls` |
| 进入某个文件夹 | 双击文件夹图标 | `cd 文件夹名` |
| 返回上一层 | 点击地址栏的上一级 | `cd ..` |
| 看当前在哪里 | 看地址栏 | `pwd`（print working directory） |
| 创建新文件夹 | 右键 → 新建文件夹 | `mkdir 文件夹名` |
| 删除文件 | 右键 → 删除 | `rm 文件名` |
| 复制文件 | Ctrl+C / Ctrl+V | `cp 源文件 目标位置` |
| 移动/重命名文件 | 拖动 / F2 | `mv 源文件 目标` |
| 查看文件内容 | 双击打开 | `cat 文件名` 或 `less 文件名` |

#### 路径：绝对路径 vs 相对路径

```
绝对路径：从根目录出发，完整地址
  /home/yourname/projects/workflow/README.md    ← Linux/macOS
  C:\Users\yourname\projects\workflow\README.md ← Windows

相对路径：从你当前所在位置出发
  ./README.md          ← 当前目录下的 README.md
  ../principles.md     ← 上一级目录的 principles.md
  ../../              ← 上两级
  .                    ← 当前目录（这个点）
  ~                    ← 你的家目录（/home/yourname 或 /Users/yourname）
```

#### 典型工作流程（试着敲一次就懂了）

```bash
# 1. 看我在哪
pwd
# → /home/yourname

# 2. 这里有什么？
ls
# → Documents  Downloads  projects  ...

# 3. 进入 projects
cd projects

# 4. 建一个新目录
mkdir my-workflow

# 5. 进去
cd my-workflow

# 6. 现在路径是 /home/yourname/projects/my-workflow
pwd

# 7. 返回家目录
cd ~
```

### 2.3 环境变量与 PATH

**PATH** 是一个特殊的 Shell 变量，告诉系统「去哪些目录找可执行程序」。

比如你敲 `ls`，系统会在 PATH 里的每个目录中找名叫 `ls` 的程序，找到了就运行。

```bash
# 看当前 PATH
echo $PATH
# → /usr/local/bin:/usr/bin:/bin:...

# PATH 里的每个目录用冒号 : 分隔（Windows 用分号 ;）
```

Nix 会往 PATH 里加自己的目录（`/nix/store/...`），这样 `nix develop` 后你的 Shell 就自动能用到所有锁定版本的依赖。

> **这和 Windows 的 `环境变量` 是一个概念**——右键「此电脑」→ 属性 → 高级系统设置 → 环境变量，看到的就是类似的东西。

---

## 3. 安装 Nix：一次装好所有东西

### 3.1 为什么用 Nix？

~~因为作者用 NixOS。~~ 真正的原因很简单：**我不想写安装脚本。**

传统开发环境的分发要么给你一个又臭又长的 README 叫你装 Python、装 Node、装 Pandoc、装 LibreOffice……要么打包一个 Docker 镜像。前者在不同机器上永远跑不齐，后者每次改工具链都要重新 build 镜像。

Nix 的思路：

```
flake.nix 就是一个声明：
  "给我 Python 3.14、Node.js 24、Chrome、Pandoc、LibreOffice，
   再加上 pillow、jieba、wordcloud 这些 Python 包。"

nix develop → 全部就位，一个不差。
退出 → 系统毫发无伤。
队友用同一个 flake.nix → 他那边是逐比特一模一样的。
```

类比：`flake.nix` 是你的「开发环境的 Dockerfile」，`nix develop` 是 `docker-compose up`。但 Nix 不虚拟化、不包一层——纯文件级别隔离，所有东西在 `/nix/store/` 下，每个包的路径包含其内容哈希，不同版本不会互相覆盖。

因为 flake 已经成了 Nix 生态的**事实标准**（社区用、文档写、CI/CD 支持），选它不用纠结。

### 3.2 安装步骤

> 三种系统的安装命令完全一样。

打开终端，粘贴一行：

#### macOS / Linux / WSL

**多用户安装（推荐）**：

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

这是 Determinate Systems 提供的安装脚本（比官方脚本更友好）：
- 自动检测系统
- 配置 flake 支持
- 卸载也方便（`/nix/nix-installer uninstall`）

**官方安装（备选）**：

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

> 安装过程会要你输一次 sudo 密码。等 2-3 分钟。结束后关掉终端重新打开。

**验证安装成功**：

```bash
nix --version
# → nix (Nix) 2.x.x
```

**启用 flake 功能**：

Nix 的 flake 是实验性功能但已经稳定了。需要手动开启：

编辑 `~/.config/nix/nix.conf` 或用一行命令追加：

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

重启终端（或 `exec $SHELL`），然后验证：

```bash
nix flake --help
# 看得到帮助信息，说明 flake 功能已启用
```

---

## 4. 获取项目 & 一键启动

### 4.1 克隆项目

```bash
# 进入你想放项目的目录
cd ~/projects   # 或者你自己习惯的地方

# 克隆
git clone <你的仓库地址> my-project
cd my-project/workflow
```

复制整个 `workflow/` 目录到你的项目里，或者直接在这个目录下工作。

### 4.2 写入 API Key（可选）

`anysearch` skill 需要联网搜索能力。这个 skill 是**可选的**——不配 key 只是用不了联网搜索，不影响其他 11 个 skill 和所有 SOP 工作流。

如果需要，去 https://anysearch.com 注册获取 API Key：

```bash
# 需要时再配
echo "你的api-key-here" > anysearchkey.env
```

不配也行，Agent 不会报错，只是跳过联网搜索。

### 4.3 进入开发环境

```bash
nix develop
```

**首次运行**会下载依赖——取决于网速，等 5-15 分钟。之后每次秒进。

进入后你会看到 Shell 提示符变了，同时终端输出：

```
欢迎进入pbl workflow环境，输入opencode打开opencode tui吧
```

`npm install` 会自动执行，把 PptxGenJS / React / Sharp 等 JS 依赖装好。

### 4.4 启动 OpenCode

```bash
opencode
```

你会看到一个 TUI（终端用户界面），顶部显示项目信息，底部是输入框。这就是你跟 AI Agent 对话的地方。

### 4.5 一键流程总览

```bash
# 假设你已经装了 Nix、克隆了项目

cd ~/projects/my-project/workflow   # 进入目录
# echo "sk-your-key" > anysearchkey.env  # 可选：写入 AnySearch API Key
nix develop                         # 进入隔离开发环境
opencode                            # 启动 AI Agent
```

然后直接在 opencode 里说你的需求，比如：

```
"我们选题是 College Life，brainstorm.txt 在上一级目录，帮我整理成研究计划"
```

---

## 5. 技术栈详解

下面是 `flake.nix` 里锁定的每一个工具/包的用途、怎么修改、去哪儿找文档。

### 5.1 核心引擎

| 工具 | 版本来源 | 作用 | 文档 |
|------|---------|------|------|
| **opencode** | nixpkgs | AI Agent 主引擎，读 AGENTS.md + SOP 驱动任务 | https://opencode.ai |
| **git** | nixpkgs | 版本管理、克隆项目 | https://git-scm.com/doc |

### 5.2 数据处理（Python）

| 包 | 作用 | 典型使用场景 |
|------|------|-------------|
| `python314` | Python 3.14 运行时 | 数据分析脚本 |
| `requests` | HTTP 请求 | 调 API、下载文件 |
| `pillow` | 图片处理 | 词云生成、PNG 裁切/缩放 |
| `markitdown` | .pptx → 纯文本提取 | 读取队友的 PowerPoint 文件 |
| `ddgs` | DuckDuckGo 搜索 | 图片搜索、资料检索 |
| `jieba` | 中文分词 | 访谈文本分词，为词云做准备 |
| `wordcloud` | 词云生成 | 从分词结果生成 PNG 词云 |
| `python-docx` | Word 文档操作 | 生成/编辑 .docx 报告 |
| `defusedxml` | 安全 XML 解析 | pptx 读取的安全依赖 |

**修改 Python 依赖**：编辑 `flake.nix`，在 `packages` 列表里加或删 `python314Packages.xxx`。

**查找可用的 Python 包**：https://search.nixos.org/packages?channel=unstable&query=python314Packages

### 5.3 文档与渲染

| 工具 | 作用 | 典型场景 |
|------|------|---------|
| `pandoc` | 文档格式转换（markdown ↔ docx ↔ html 等） | 把 script.md 转成 Word、把 HTML 转成 markdown |
| `libreoffice` | 办公套件（无头模式） | 把 .pptx 渲染为 PDF，做 QA 检查 |
| `poppler-utils` | PDF 工具集 | `pdftoppm`：把 PDF 页面转成 JPG 图片，逐页视觉检查 |

### 5.4 前端 / PPT 引擎（Node.js）

| 包 | 作用 | 典型场景 |
|------|------|---------|
| `nodejs_24` | Node.js 运行时 | 跑 build.js（HTML → PPTX 生成） |
| `pptxgenjs` (npm) | 纯 JS 生成 .pptx | HTML slide 结构 → 真正的 PowerPoint 文件 |
| `react` + `react-dom` (npm) | UI 框架 | HTML 幻灯片模板的运行时依赖 |
| `react-icons` (npm) | 图标库 | 幻灯片里的 UI 图标（箭头、勾、叉等） |
| `sharp` (npm) | 高性能图片处理 | 幻灯片里的图片优化 |

### 5.5 浏览器自动化

| 工具 | 作用 | 典型场景 |
|------|------|---------|
| `google-chrome` | Chrome 浏览器 | `agent-browser` skill 的运行时——打开网页、填表单、截图 |
| `agent-browser` | 浏览器自动化 CLI | 由 `agent-browser` skill 调用 |

> Chrome 的路径通过环境变量 `AGENT_BROWSER_EXECUTABLE_PATH` 注入，已写在 flake.nix 里，不用动。

### 5.6 Skills（Agent 的能力插件）

Skills 放在 `.agents/skills/` 目录。每个 skill 是一个文件夹，里面有一份 `SKILL.md` 定义工作流。Agent 读到对应 SOP 时，会加载相应的 skill。

当前内置的 skills：

| Skill | 来源 | 做什么 |
|-------|------|--------|
| `html-ppt` | 内置 | 36 主题 × 15 模板的 HTML 幻灯片生成 |
| `pptx` | 内置 | 读取 .pptx（markitdown）、创建 .pptx（PptxGenJS） |
| `chart-visualization` | 内置 | 调用 AntV API 生成柱状图/雷达图/桑基图 |
| `image-search` | 内置 | DuckDuckGo 图片搜索 |
| `image-processing` | 内置 | Pillow 图片处理 |
| `anysearch` | 内置 | AnySearch API 联网搜索（需自行申请 key，可选） |
| `wenjuanxing-export` | 内置 | 问卷星格式问卷输出 |
| `designing-surveys` | 内置 | 问卷设计方法论 |
| `speech-writer` | 内置 | 演讲稿撰写 |
| `research-paper-writer` | 内置 | IEEE/ACM 学术论文写作 |
| `agent-browser` | 内置 | 浏览器自动化 |
| `notify-send` | 内置 | Linux 桌面通知 |
| `docx-manipulation` | `skills-lock.json` 锁定 | Word 文档操作（来自 github:claude-office-skills） |

---

## 6. 自定义与扩展

### 6.1 添加新的 Skill

有两种方式：

#### 方式 A：从 OpenCode Hub 安装（推荐）

在 opencode 对话中直接说：

```
"帮我安装一个 xxx 的 skill"
```

或者自己运行：

```bash
opencode skill install <skill-name>
```

安装后的 skill 会出现在 `.agents/skills/` 下，哈希值记录到 `skills-lock.json`。

#### 方式 B：手动添加

1. 把 skill 文件夹（含 `SKILL.md`）放到 `.agents/skills/<skill-name>/`
2. 如果 skill 来自 GitHub，在 `skills-lock.json` 中登记：

```json
{
  "version": 1,
  "skills": {
    "<skill-name>": {
      "source": "github-user/repo",
      "sourceType": "github",
      "skillPath": "<skill-name>/SKILL.md",
      "computedHash": "<自动计算的哈希>"
    }
  }
}
```

### 6.2 添加更多系统级工具

编辑 `flake.nix` 的 `packages` 列表，加一行：

```nix
packages=with pkgs;[
  # ... 已有的 ...
  imagemagick    # 你想加的新工具
];
```

然后退出 `nix develop`（按 Ctrl+D 或输 `exit`），重新 `nix develop`。

**查找有什么包可用**：https://search.nixos.org/packages

常用包示例：
- `imagemagick` — 强大的图片处理
- `ffmpeg` — 音视频处理
- `graphviz` — 流程图/关系图
- `jq` — JSON 处理
- `ripgrep` — 超快的文本搜索
- `fd` — 超快的文件查找
- `hugo` — 静态网站生成器

### 6.3 添加 Python 包

在 `flake.nix` 的 `packages` 列表里加：

```nix
python314Packages.numpy        # 数值计算
python314Packages.matplotlib   # 数据可视化
python314Packages.scipy        # 科学计算
python314Packages.pandas       # 数据分析
```

查找所有可用 Python 包：
https://search.nixos.org/packages?channel=unstable&query=python314Packages.

### 6.4 添加 Node.js 包（npm）

编辑 `package.json` 的 `dependencies`，然后重新进入 `nix develop` 或者在 shell 里跑：

```bash
npm install <package-name>
```

常用：
- `playwright` — 浏览器自动化（比 agent-browser 更灵活）
- `@anthropic-ai/sdk` — 直接调 Claude API
- `chart.js` — 浏览器端图表

---

## 7. 查找资源

### 核心工具的官方文档

| 工具 | 文档 |
|------|------|
| OpenCode | https://opencode.ai |
| Nix | https://nixos.org/learn |
| Nixpkgs 包搜索 | https://search.nixos.org/packages |
| Nix flake 手册 | https://nixos.wiki/wiki/Flakes |
| PptxGenJS | https://github.com/gitbrent/PptxGenJS |
| Pandoc | https://pandoc.org/MANUAL.html |
| LibreOffice | https://help.libreoffice.org/latest/en-US/text/shared/guide/start_parameters.html |

### Skill 资源

- OpenCode 内置 skill 文档：`.agents/skills/<skill-name>/SKILL.md`
- `html-ppt` 模板和主题：`.agents/skills/html-ppt/templates/` 和 `assets/`
- `html-ppt` 自带示例：`.agents/skills/html-ppt/examples/`
- `pptx` skill 的脚本工具：`.agents/skills/pptx/scripts/`

### 项目内文档

| 文件 | 内容 |
|------|------|
| `README.md` | 功能概述、技术栈、OS 支持 |
| `principles.md` | 5 大设计原则、SOP 范式、多 Agent 协作 |
| `AGENTS.md` | 你的项目配置（填空后）——Agent 的总控制器 |
| `docs/SOP-*.md` | 6 个 SOP 操作手册——每个阶段的完整工作流 |

---

## 8. 常见问题

### Q: `nix develop` 后提示找不到 flake.nix？

确保终端当前目录是项目根目录（`pwd` 确认一下），且目录下有 `flake.nix` 文件。

### Q: `nix develop` 下载很慢？

首次下载需要拉取整个依赖树（~2-5 GB）。可以配置中国镜像加速：

```bash
# 在 ~/.config/nix/nix.conf 中追加
substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://cache.nixos.org/
```

### Q: `opencode` 命令找不到？

`opencode` 只在 `nix develop` 环境内可用。先进入环境再启动。

### Q: Agent 不读我的 brainstorming 文件？

确认文件名和路径与 `AGENTS.md` 中的「关键文件」表一致，文件名区分大小写。如果改了文件名忘记更新 AGENTS.md，Agent 找不到。

### Q: 怎么退出 nix develop 环境？

按 `Ctrl + D` 或输入 `exit`。

### Q: 我在 Windows 上，WSL2 的文件在哪？

- WSL 里访问 Windows 文件：`/mnt/c/Users/yourname/`
- Windows 里访问 WSL 文件：文件管理器地址栏输 `\\wsl$\Ubuntu\home\yourname\`

### Q: 可以不用 Nix 吗？

可以——手动装 Python 3.14 + Node.js 24 + 所有 Python 包 + Chrome + Pandoc + LibreOffice。但此刻你在给自己写一份安装脚本（在不同 OS 上行为还不一样）。

用 `flake.nix` 的好处：**开发环境就是发布环境**。你配好一次，队友 `nix develop` 进去，东西一模一样。你不需要写"Ubuntu 请用 apt-get install xxx, macOS 请用 brew install yyy, Windows 请用 WSL 然后 apt-get install xxx"——`flake.nix` 一份文件全平台通用。

### Q: `skills-lock.json` 里的 hash 不匹配怎么办？

删除 `skills-lock.json` 中对应 skill 的条目，重新安装该 skill。Agent 会自动计算新的 hash。

### Q: 我想换个主题颜色 / 模板？

HTML 幻灯片的主题在 `html-ppt` skill 的 assets 里——36 种主题，在 opencode 对话中说「帮我换 xxx 主题」或者在 `index.html` 中改 `data-theme` 属性。

模板在 `.agents/skills/html-ppt/templates/`，有 15 种（presenter-mode-reveal 是本 workflow 的默认模板）。

---

## 附录：命令速查卡

```bash
# ── 环境相关 ──────────────────────
nix develop              # 进入隔离开发环境
exit                     # 或 Ctrl+D，退出
nix flake update         # 更新 flake.lock（拉最新依赖）

# ── 文件相关 ──────────────────────
ls                       # 列出文件
cd <dir>                 # 进入目录
pwd                      # 看当前位置
mkdir <dir>              # 建目录
cat <file>               # 看文件内容

# ── 项目相关 ──────────────────────
echo "key" > anysearchkey.env  # 写入 API Key
opencode                  # 启动 AI Agent
git pull                  # 拉取最新代码

# ── Node.js 相关（在 nix develop 内）──
npm install <pkg>         # 加一个 JS 包
npm ls                    # 查看已安装的 JS 包
```
