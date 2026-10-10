# 自己更新网站：操作指南

## 打开正确入口

VS Code / Cursor：“文件 → 从文件打开工作区” → 根目录 `website.code-workspace`。其中“01-网站源码”就是 `site/`，“02-CV与个人材料”就是 `cv/`。

旧标签 `academic-homepage/publications.html` 已失效，重新打开 `site/publications.html`。论文内容通常不改这个页面，而是改 `site/_publications/` 的对应文件。

## 日常修改

| 文件（相对 site/） | 修改方法 |
| --- | --- |
| `_data/profile.yml` | `positions` 侧栏身份；`sidebar_bio` 侧栏短简介；`short_bio` 首页长简介；`education` 教育数据。这些是不同展示位置，身份变化时一起检查 |
| `_data/research.yml` | 一行一个方向，按列表顺序显示 |
| `_data/internships.yml` | 一段一个实习；`organization` 单位、`date` 显示日期、`datetime` 机器可读日期、`logo` 校徽 |
| `_data/service.yml` | 在 `reviewer` 下增减会议 |
| `_data/highlights.yml` | Highlights 的奖项；该页不再展示论文 |
| `_data/projects.yml` | 精选 GitHub 项目；`featured: true` 控制首页的简短预览 |
| `_data/navigation.yml` | 导航名称、链接、顺序 |
| `_data/display.yml` | News、精选论文等开关，以及首页新闻条数 |

YAML 用空格缩进，不用 Tab；含冒号的普通文本加引号。图片路径写 `/assets/images/...`，图片放 `site/assets/images/...`。

## 论文：一篇一个文件

按会议年份放在 `site/_publications/2026/`、`2027/` 等目录。复制同类现有文件修改即可。

- `title`：展示标题；在审稿件只用宽泛研究方向，不写真题目。
- `date`：条目实际日期，保持现有格式。
- `pub` / `pub_date`：会议名称 / 会议年份；年份加引号。
- `rank`：越小越靠前；当前已录用是 1、2、3，在投是 101、102、103。
- `selected: true`：同时出现在首页。
- `abstract`：简述；在审稿件不写具体方法或实验结果。
- `cover`：论文主图截图路径，如 `/assets/images/covers/image-evaluation.png`。只截主图区域，避开真实题目、作者、投稿编号及页眉；不添加专门的匿名或在审说明行。
- `authors`：公开条目的作者顺序；链接信息在 `_data/authors.yml`。
- `anonymous: true`：在审匿名展示。不要把真实题目、作者、稿件链接写进此文件，即使页面不显示也不应公开提交。

当前在审条目的格式示例（不要新增重复条目）：

```yaml
---
title: Generated Image Evaluation
date: 2026-09-29 00:00:00 +0800
rank: 101
selected: true
anonymous: true
pub: AAAI
pub_date: "2027"
pub_last: '<span class="badge badge-info">Under Review · Phase 2</span>'
abstract: Research on assessing whether generated images satisfy textual instructions.
---
```

录用后，确认可以公开再更新题目、作者和状态，移除 `anonymous: true`，调整 `rank`。同时检查简介、News、Highlights 和 CV；LaTeX CV 不会自动从网站数据生成。

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

此处仅是格式示例，不要发布未发生的事项。首页显示最新若干条，News 页面显示完整列表。

## 页面结构

- 首页板块顺序：`site/index.html`。当前为简介 → 研究方向 → 学术服务 → News → 论文。
- Publications / Projects / Intern / Highlights 页面结构：`site/publications.html` / `projects.html` / `intern.html` / `awards.html`。
- 公共侧栏：`site/_includes/widgets/homepage_sidebar.html`。
- 公共论文卡片：`site/_includes/widgets/publication_item.html`。
- CSS：`site/assets/css/global.css`。修改后可更新 `_config.yml` 的 `asset_version` 字符串，让浏览器重新加载；相应测试也需同步预期。

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

中英文主简历均为两页：第一页为个人背景及论文，第二页为研究工作、项目、奖项和技能。照片版及旧版保留原用途。各版本用途见 [cv/README.md](../cv/README.md)。只编译中英文主简历：

```sh
ruby tools/website.rb cv cheng-chen-cv cheng-chen-cv-zh
```

PDF 写回 `cv/`，辅助文件在 `.build/cv/`。发布前打开 PDF 检查排版，身份、日期、排名、实习、审稿服务和论文状态需与网站一致。

`.local/submissions/` 是私有 PDF，`.local/archive/` 是历史归档。根目录 HTML、`assets/`、`2026/` 是自动发布输出，直接修改会被下一次构建覆盖。不要为了改网站翻找这些副本，也不要在旧源码路径新建文件。
