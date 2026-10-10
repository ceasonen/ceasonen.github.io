# 自己更新网站：操作指南

## 打开正确入口

VS Code / Cursor：“文件 → 从文件打开工作区” → 根目录 `website.code-workspace`。其中“01-网站源码”就是 `site/`，“02-CV与个人材料”就是 `cv/`。

主页已改为单页展示。旧标签 `academic-homepage/publications.html` 已失效；调整页面结构打开 `site/index.html`，修改论文打开 `site/_publications/` 的对应文件。根目录页面都是生成副本。

## 日常修改

| 文件（相对 site/） | 修改方法 |
| --- | --- |
| `_data/profile.yml` | `short_bio` 首页简介；`education` 教育（`detail` 显示本科排名）；`email` 校内邮箱、`additional_email` Gmail；联系方式和头像。当前侧栏单位固定为 Tongji University |
| `_data/research.yml` | 一行一个方向，按列表顺序显示 |
| `_data/internships.yml` | 一段一个实习；`organization` 单位、`date` 显示日期、`datetime` 机器可读日期、`logo` 校徽 |
| `_data/service.yml` | 在 `reviewer` 下增减会议 |
| `_data/highlights.yml` | 首页奖项列表 |
| `_data/projects.yml` | 首页精选 GitHub 项目，Projects 板块直接展示全部条目 |
| `_data/navigation.yml` | 导航名称、顺序；板块链接格式 `/#publications` 等 |

YAML 用空格缩进，不用 Tab；含冒号的普通文本加引号。图片路径写 `/assets/images/...`，图片放 `site/assets/images/...`。

## 论文：一篇一个文件

按会议年份放在 `site/_publications/2026/`、`2027/` 等目录。复制同类现有文件修改即可。

- `title`：论文真实题目；当前四篇 Preprint 已获授权展示题目。
- `date`：条目实际日期，保持现有格式。
- `pub` / `pub_date`：会议名称 / 会议年份；年份加引号。
- `venue_short`：可选的会议简称（如 `ACM MM`、`IJCAI`），用于论文卡片展示；完整会议名称仍保存在 `pub`。
- `preprint_year`：预印本年份；当前四篇匿名稿件均为 `"2026"`。网站以 Preprint 展示，原投稿会议字段保留作维护记录。
- `rank`：越小越靠前；当前已录用是 1、2、3，在投是 101、102、103、104。
- `links`：已核实的论文页面，键名可用 `arXiv` 或 `ResearchGate`；网址和题目必须匹配。当前已录用论文均已添加，核验记录见 [publication-links.md](publication-links.md)。
- 首页按 `rank` 显示全部论文，一篇只展示一次。
- `abstract`：简述；在审稿件不写具体方法或实验结果。
- `cover`：论文主图截图路径，如 `/assets/images/covers/image-evaluation.png`。只截主图区域，避开真实题目、作者、投稿编号及页眉；不添加专门的匿名或在审说明行。
- `authors`：公开条目的作者顺序；链接信息在 `_data/authors.yml`。
- `anonymous: true`：隐藏作者及稿件链接；现在仍显示真实题目。不要把未授权作者或私人稿件链接写进文件，即使页面不显示也不应公开提交。

当前在审条目的格式示例（不要新增重复条目）：

```yaml
---
title: "From Scores to Checks: A Human-Annotated Rubric Benchmark for AI-Generated Image Faithfulness"
date: 2026-09-29 00:00:00 +0800
rank: 101
selected: true
anonymous: true
pub: AAAI
pub_date: "2027"
preprint_year: "2026"
pub_last: '<span class="badge-publication">Preprint</span>'
abstract: Research on assessing whether generated images satisfy textual instructions.
---
```

录用后，确认作者与稿件可以公开再补充作者、链接和状态，移除 `anonymous: true`，调整 `rank`。同时检查简介、News 和 CV；LaTeX CV 不会自动从网站数据生成。

## News：一条一个文件

在 `site/_news/` 新建 `YYYY-MM-DD-topic.md`，参考现有条目：

```yaml
---
title: "Our work has been accepted at **Conference 2027**."
date: 2027-01-01 00:00:00 +0800
category: "publication"
badge: "Accepted"
---
```

此处仅是格式示例，不要发布未发生的事项。首页 News 滚动区域按时间显示完整列表。

## 页面结构

- 首页板块顺序：`site/index.html`。当前为简介及研究方向 → News → 教育与实习 → 项目 → 奖项 → 论文 → 学术服务。导航顺序与板块一致，独立的 CV 下载按钮保留在最后。
- 页面外壳：`site/_layouts/single.html`；侧栏：`site/index.html`。
- 教育实习 / 项目 / 论文布局：`site/_includes/sections/experience.html` / `projects.html` / `publications.html`。
- 原独立栏目页面仅保留旧地址跳转，使用 `site/_layouts/redirect.html`，无需重复维护内容。
- 单页导航脚本：`site/assets/js/home.js`，负责手机菜单和当前板块提示。
- CSS：`site/assets/css/global.css`。修改后可更新 `_config.yml` 的 `asset_version` 字符串，让浏览器重新加载；相应测试也需同步预期。
- 网站字体参考 WowPage：正文优先使用系统 Arial Rounded MT Bold，后备 Comic Sans MS / Verdana；欢迎标题使用 Permanent Marker（Google Fonts）。不分发系统商业字体文件。主 CV 与照片简历使用 Computer Modern Unicode（TeX Live 自带 OpenType 字体），中文保留宋体；不受网站字体影响。
- 本轮直接以克隆的 WowPage 源码为基础调整；样式来源和改进说明见 [design-reference.md](design-reference.md)。论文区的三个筛选按钮共用同一组卡片，不需要重复维护内容；联系图标在 `site/_includes/widgets/icon.html`。

## 构建、预览、发布

在根目录运行命令；维护工作区默认终端也位于根目录。“终端 → 运行任务”中有同名快捷任务。

```sh
ruby tools/website.rb build
ruby tools/website.rb preview
```

浏览器打开 `http://127.0.0.1:4000`，`Ctrl+C` 停止。预览只提供构建后的公开网站和主 CV，不提供论文工作目录或私有在审稿。

修改后在另一个终端运行 `build`，再刷新浏览器；主 CV 重新编译后也运行 `build` 即可同步预览 PDF。以后新增下载链接时需显式扩展 `tools/build_site.rb` 的公开预览文件清单。

首次在新机器准备依赖：

```sh
cd site
bundle install
cd ..
```

需要 Ruby、Bundler、Jekyll；预览需要 WEBrick（当前环境已具备）。CV 编译需要 TeX Live 和模板使用的字体。

构建通过后检查 `git status` / `git diff`，只暂存本次相关源码和生成文件，提交后执行 `git push origin main`。**不要用 `git add .` 混入论文工作文件，不要提交 `.local/`。** 维护命令不自动执行 Git 写操作。

## CV 与本地材料

中英文主简历均为两页：第一页为教育、MAIN INTERESTS、已录用论文、预印本、实习和学术服务；第二页逐篇介绍七项研究，再列奖项与技能。成绩当前为均分 92/100、GPA 4.70（未添加满分制）、排名 2/85。中文 MAIN INTERESTS 保留指定原句，英文为对应翻译。Preprint 显示真实题目但不列作者。精选 GitHub 项目只放网站，不放 CV。照片版及旧版保留原用途。各版本用途见 [cv/README.md](../cv/README.md)。只编译中英文主简历：

```sh
ruby tools/website.rb cv cheng-chen-cv cheng-chen-cv-zh
```

PDF 写回 `cv/`，辅助文件在 `.build/cv/`。发布前打开 PDF 检查排版，身份、日期、排名、实习、审稿服务和论文状态需与网站一致。

`.local/submissions/aaai-2027/` 有一份当前 AAAI 稿件，`iclr-2027/` 有三份当前 ICLR 稿件；文件映射见 `.local/submissions/README.md`。旧下载在 `.local/submissions/archive/2026-09/`，原 NeurIPS 稿件在 `archive/neurips-2026/`。这些资料仅在本地保存。

根目录 HTML、`assets/`、`2026/` 是自动发布输出，直接修改会被下一次构建覆盖。不要为了改网站翻找这些副本，也不要在旧源码路径新建文件。
