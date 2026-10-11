# 目录整理说明

## 主版本与发布副本

网站唯一源码在 `site/`（原 `academic-homepage/` 已整体改名），根目录 HTML 和 `assets/` 是发布副本。运行 `ruby tools/website.rb build` 后，导航和侧栏会一起更新，并执行链接及内容检查。

日常编辑推荐打开根目录 `website.code-workspace`，按网站、CV、论文、证书、维护指南、工具、测试分组。根目录发布副本不显示在工作区中，避免改错。逐项修改入口见 [editing-guide.md](editing-guide.md)。

`projects/Image2Other/` 是独立 Git 仓库，工作区的“08-Image2Other 独立项目”直接打开其源码。它自行构建和发布到 `https://ceasonen.github.io/Image2Other/`，不属于主页构建输出，也不会随主页提交一起暂存。主页只在 `site/_data/projects.yml` 维护展示介绍和入口。新机器需要另行克隆 `https://github.com/ceasonen/Image2Other.git` 到该路径；项目依赖和测试截图留在项目自己的忽略目录。

CV 和论文分别只在根目录 `cv/`、`papers/` 维护。旧的 `academic-homepage/cv/`、`academic-homepage/papers/` 已比对并完整移入 `.local/archive/source-mirrors-*/`，可按归档说明恢复。论文模板依赖和研究笔记保留在根目录论文目录，避免影响编译。

## 编译文件与归档

- `.build/site/`：最新网站构建结果。
- `.build/cv/<文档名称>/`：简历 PDF、辅助文件和 `build.log`。
- `.local/archive/<整理时间>/`：历史输出、截图、重复证书和散落编译文件。
- `.local/submissions/<会议年份>/`：稿件的本地 PDF，不提交 Git、不进入网站构建。公开条目按最新授权展示真实题目、概括及 Preprint 状态，但不列作者、不提供稿件链接。网站使用主图局部截图作封面；截图不含作者、投稿编号、页眉或图注，原始 PDF 仍保持私有。

每次归档创建独立时间目录，`manifest.json` 记录原始相对路径。恢复时，将目标文件复制回相同的仓库相对路径；若当前位置已有文件，先比较内容，避免覆盖新版本。

例如，将 `.local/archive/<整理时间>/cv/rubbish/` 复制回 `cv/rubbish/`，即可恢复该历史目录。

重复证书逐字节比较，确认与 `awards/` 一致后才归档。整理不使用哈希计算或校验，也不永久删除文件。源码、`.bbl` 和模板依赖不作为垃圾处理。

## 维护原则

1. 编译文件放 `.build/`，历史本地材料放 `.local/`。
2. 证书放 `awards/`，论文放 `papers/<会议>/`，简历放 `cv/`。
3. 使用构建脚本同步发布文件，避免将整个 Jekyll 输出目录复制到根目录。
4. 整理不自动提交论文目录中原本未跟踪的研究笔记或文件。
5. `bio.jpg` 和 `cv/.latexmkrc` 原有的删除状态不由整理脚本恢复或提交。
