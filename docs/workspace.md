# 目录整理说明

## 主版本与发布副本

网站源码在 `academic-homepage/`，根目录 HTML 和 `assets/` 是发布副本。运行 `ruby tools/build_site.rb` 后，所有页面的导航与侧栏会一起更新。

CV 和论文分别只在根目录 `cv/`、`papers/` 维护。旧的 `academic-homepage/cv/`、`academic-homepage/papers/` 已比对并完整移入 `.local/archive/source-mirrors-*/`，可按归档说明恢复。论文模板依赖和研究笔记保留在根目录论文目录，避免影响编译。

## 编译文件与归档

- `.build/site/`：最新网站构建结果。
- `.build/cv/<文档名称>/`：简历 PDF、辅助文件和 `build.log`。
- `.local/archive/<整理时间>/`：历史输出、截图、重复证书和散落编译文件。
- `.local/submissions/<会议年份>/`：在审稿件的本地 PDF，不提交 Git、不进入网站构建。公开页面只展示投稿数量和阶段。

每次归档创建独立时间目录，`manifest.json` 记录原始相对路径。恢复时，将目标文件复制回相同的仓库相对路径；若当前位置已有文件，先比较内容，避免覆盖新版本。

例如，将 `.local/archive/<整理时间>/cv/rubbish/` 复制回 `cv/rubbish/`，即可恢复该历史目录。

重复证书逐字节比较，确认与 `awards/` 一致后才归档。整理不使用哈希计算或校验，也不永久删除文件。源码、`.bbl` 和模板依赖不作为垃圾处理。

## 维护原则

1. 编译文件放 `.build/`，历史本地材料放 `.local/`。
2. 证书放 `awards/`，论文放 `papers/<会议>/`，简历放 `cv/`。
3. 使用构建脚本同步发布文件，避免将整个 Jekyll 输出目录复制到根目录。
4. 整理不自动提交论文目录中原本未跟踪的研究笔记或文件。
5. `bio.jpg` 和 `cv/.latexmkrc` 原有的删除状态不由整理脚本恢复或提交。
