# 自己更新网站：操作指南

## 打开正确入口

VS Code / Cursor：“文件 → 从文件打开工作区” → 根目录 `website.code-workspace`。其中“01-网站源码”就是 `site/`，“02-CV与个人材料”就是 `cv/`。

主页已改为单页展示。旧标签 `academic-homepage/publications.html` 已失效；调整页面结构打开 `site/index.html`，修改论文打开 `site/_publications/` 的对应文件。根目录页面都是生成副本。

## 日常修改

| 文件（相对 site/） | 修改方法 |
| --- | --- |
| `_data/profile.yml` | `short_bio` 首页简介和唯一一段研究兴趣；`education` 教育（`detail` 显示本科排名，`logo` 和 `logo_alt` 指定校徽与说明）；`email` 校内邮箱、`additional_email` Gmail；联系方式和头像。当前侧栏单位固定为 Tongji University |
| `_data/internships.yml` | 一段一个实习；`organization` 单位、`date` 显示日期、`datetime` 机器可读日期、`logo` 校徽 |
| `_data/service.yml` | 在 `reviewer` 下增减会议 |
| `_data/highlights.yml` | 奖项卡片：`name` 比赛全称、`prize` 奖级、`date` 年份、`role` 角色、`detail` 补充、`featured` 突出展示 |
| `_data/projects.yml` | 首页精选 GitHub 项目，Projects 板块直接展示全部条目；可选 `website` 字段显示在线工具入口 |
| `_data/navigation.yml` | 导航名称、顺序；板块链接格式 `/#publications` 等 |

YAML 用空格缩进，不用 Tab；含冒号的普通文本加引号。图片路径写 `/assets/images/...`，图片放 `site/assets/images/...`。

比赛名称依据见 [competition-names.md](competition-names.md)：英文名同步维护奖项、相关 News 和当前英文 CV；有明确组委会英文名时优先采用，没有统一英文声明时使用有出处的高校或赛事参与方译名，不自行标为“唯一官方英文名”。

## 论文：一篇一个文件

按会议年份放在 `site/_publications/2026/`、`2027/` 等目录。复制同类现有文件修改即可。

- `title`：论文真实题目；当前四篇 Preprint 已获授权展示题目。
- `date`：条目实际日期，保持现有格式。
- `pub` / `pub_date`：会议名称 / 会议年份；年份加引号。
- `venue_short`：可选的会议简称（如 `ACM MM`、`IJCAI`），用于论文卡片展示；完整会议名称仍保存在 `pub`。
- `preprint_year`：预印本年份；当前四篇匿名稿件均为 `"2026"`。网站以 Preprint 展示，原投稿会议字段保留作维护记录。
- `rank`：越小越靠前；当前已录用是 1、2、3，在投是 101、102、103、104。
- `links`：统一使用 `PDF` 键名，网址必须直接打开论文 PDF，而不是摘要页面或登录页面。当前两篇使用 arXiv `/pdf/` 地址，IJCNN 使用明确公开的 `site/assets/papers/deepyolo-ijcnn-2026.pdf`；核验记录见 [publication-links.md](publication-links.md)。不要上传 `.local/` 在审稿件。
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

此处仅是格式示例，不要发布未发生的事项。首页 News 滚动区域按时间显示完整列表。同一批投稿合并为一条；有汇总消息就不保留重复的单篇消息。比赛名称使用全称，不额外追加 CRAIC / CMC 等括号简写。

## 页面结构

- 首页板块顺序：`site/index.html`。当前为简介及研究方向 → News → 教育与实习 → 项目 → 奖项 → 论文 → 学术服务。导航顺序与板块一致，英文 CV（EN）与中文 CV（ZH）下载链接保留在最后，也都显示在左侧资料栏。
- 页面外壳：`site/_layouts/single.html`；侧栏：`site/index.html`。
- 教育实习 / 项目 / 论文布局：`site/_includes/sections/experience.html` / `projects.html` / `publications.html`。
- 原独立栏目页面仅保留旧地址跳转，使用 `site/_layouts/redirect.html`，无需重复维护内容。
- 单页导航脚本：`site/assets/js/home.js`，负责手机菜单和当前板块提示。
- CSS：`site/assets/css/global.css`。修改后可更新 `_config.yml` 的 `asset_version` 字符串，让浏览器重新加载；相应测试也需同步预期。
- 网站保持 WowPage 的圆润风格，全站统一使用本地托管的 Nunito 可变字体（`site/assets/fonts/nunito-latin.woff2`，约 38 KB，SIL 开源授权）；标题、正文、简介、奖项、论文、导航使用同一家族，以字号和字重区分层级，不混用其他正文或手写字体，也不依赖 Google Fonts 在线加载。主 CV 与照片简历仍使用 Computer Modern Unicode，中文保留宋体；不受网站字体影响。
- 本轮直接以克隆的 WowPage 源码为基础调整；样式来源和改进说明见 [design-reference.md](design-reference.md)。论文区的三个筛选按钮共用同一组卡片，不需要重复维护内容；联系图标在 `site/_includes/widgets/icon.html`。

## 构建、预览、发布

在根目录运行命令；维护工作区默认终端也位于根目录。“终端 → 运行任务”中有同名快捷任务。

```sh
ruby tools/website.rb build
ruby tools/website.rb preview
```

浏览器打开 `http://127.0.0.1:4000`，`Ctrl+C` 停止。预览只提供构建后的公开网站和中英文主 CV，不提供论文工作目录或私有在审稿。

可选浏览器验证：启动一个专用 Chrome 调试实例（端口 9225），运行 `node tests/browser_design_test.mjs`；也可追加预览地址和调试端口。该检查核验实际渲染字体、八个屏幕宽度、七个板块锚点、论文筛选、菜单与 PDF 响应，截图保存在忽略目录 `.build/preview/`。请只连接专用测试浏览器，不连接日常浏览器。

修改后在另一个终端运行 `build`，再刷新浏览器；主 CV 重新编译后也运行 `build` 即可同步预览 PDF。以后新增下载链接时需显式扩展 `tools/build_site.rb` 的公开预览文件清单。

首次在新机器准备依赖：

```sh
cd site
bundle install
cd ..
```

需要 Ruby、Bundler、Jekyll；预览需要 WEBrick（当前环境已具备）。CV 编译需要 TeX Live 和模板使用的字体。

构建通过后检查 `git status` / `git diff`，只暂存本次相关源码和生成文件，提交后执行 `git push origin main`。**不要用 `git add .` 混入论文工作文件，不要提交 `.local/`。** 维护命令不自动执行 Git 写操作。

## Image2Other 独立工具

工作区的“08-Image2Other 独立项目”对应 `projects/Image2Other/`，在线地址是 `https://ceasonen.github.io/Image2Other/`。界面在 `src/main.js` 和 `src/style.css`，场景与矢量转换在 `src/scene.js`，PPTX 导出在 `src/export.js`，模型接口在 `src/ai.js`。这是另一个 Git 仓库，不能在主页根目录替它提交。

```sh
cd projects/Image2Other
npm install --ignore-scripts
npm run dev
```

打开 `http://127.0.0.1:5178/Image2Other/`。修改后运行 `npm test` 和 `npm run build`，只在这个目录提交项目代码并推送；其 GitHub Actions 自动发布。主页项目卡片的介绍仍在 `site/_data/projects.yml`，需按主页的构建发布流程更新。详细使用、隐私边界和当前限制见项目 `README.md`。不要把模型密钥、用户图片或未授权的论文图提交到任何仓库。

## CV 与本地材料

中英文主简历均为两页：第一页为教育、Main interests、已录用论文、预印本、实习和学术服务；第二页逐篇介绍七项研究，再列奖项与技能。成绩当前为均分 92.02/100、GPA 4.70（未添加满分制）、排名 2/85。英文小标题使用句首大写，研究经历题目与论文列表的完整正式题目一致。英文 Main interests 与首页简介的研究兴趣段落一致；中文主简历与照片版同步对应的精简中文表述。首页不再另列重复的方向列表，`_data/research.yml` 只保留给旧模板参考。Preprint 显示真实题目；已确认完整署名的条目列作者和角色，另两篇只标注 Cheng Chen 的职责，不臆填其余作者。精选 GitHub 项目只放网站，不放 CV。照片版及旧版保留原用途。各版本用途见 [cv/README.md](../cv/README.md)。只编译中英文主简历：

```sh
ruby tools/website.rb cv cheng-chen-cv cheng-chen-cv-zh
```

PDF 写回 `cv/`，辅助文件在 `.build/cv/`。发布前打开 PDF 检查排版，身份、日期、排名、实习、审稿服务和论文状态需与网站一致。

`.local/submissions/aaai-2027/` 有一份当前 AAAI 稿件，`iclr-2027/` 有三份当前 ICLR 稿件；文件映射见 `.local/submissions/README.md`。旧下载在 `.local/submissions/archive/2026-09/`，原 NeurIPS 稿件在 `archive/neurips-2026/`。这些资料仅在本地保存。

根目录 HTML、`assets/`、`2026/` 是自动发布输出，直接修改会被下一次构建覆盖。不要为了改网站翻找这些副本，也不要在旧源码路径新建文件。
