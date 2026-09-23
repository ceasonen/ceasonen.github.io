# Cheng Chen 的个人主页

线上地址：https://ceasonen.github.io/

## 目录与维护入口

| 目录 / 文件 | 用途 |
| --- | --- |
| `academic-homepage/` | 网站源码：个人资料、新闻、论文列表、模板和图片 |
| `cv/` | 简历、个人陈述等材料的主版本，在这里编辑 `.tex` |
| `papers/` | 按会议分类的论文及配套文件 |
| `awards/` | 奖状与证书 |
| `tools/` | 网站构建、CV 编译及本地整理脚本 |
| `docs/` | 维护说明和原模板文档 |
| 根目录 HTML、`assets/`、`2026/` | GitHub Pages 发布文件，由网站构建命令更新 |
| `.build/` | 构建结果、LaTeX 中间文件及日志，不提交 Git |
| `.local/archive/` | 可恢复的本地归档，不提交 Git |

根目录保留发布页面，因为当前 GitHub Pages 使用根目录静态文件，并通过 `.nojekyll` 禁用二次编译。移动它们会改变现有网址。

## 修改主页

- 简介与教育经历：`academic-homepage/_data/profile.yml`
- 导航：`academic-homepage/_data/navigation.yml`
- 左侧身份栏：`academic-homepage/_includes/widgets/homepage_sidebar.html`
- 实习：`academic-homepage/intern.html`
- 新闻与论文：`academic-homepage/_news/`、`academic-homepage/_publications/`
- 样式、图片：`academic-homepage/assets/`

```sh
ruby tools/build_site.rb
ruby tools/check_site.rb
ruby academic-homepage/test/intern_page_test.rb
```

使用 `academic-homepage/Gemfile` 中的 Jekyll/Bundler 依赖。构建仅同步网页、网站资源和 favicon，不复制论文、日志、截图或测试目录。下载文件继续由根目录 `cv/`、`papers/` 提供。

## 修改 CV

英文主简历为 `cv/cheng-chen-cv.tex`，中文为 `cv/cheng-chen-cv-zh.tex`。其他文件对应照片版、个人陈述、补充材料和旧版参考。

```sh
# 编译全部简历材料
ruby tools/build_cv.rb

# 只编译中英文主简历
ruby tools/build_cv.rb cheng-chen-cv cheng-chen-cv-zh
```

需要 TeX Live（`pdflatex`、`xelatex`）及简历使用的字体。PDF 更新到 `cv/`，辅助文件和日志集中在 `.build/cv/`。旧版 PDF 仅保留在 `.build/cv/cheng-chen-cv-legacy/`。

脚本同步 `academic-homepage/cv/` 中已有的简历镜像；始终编辑根目录 `cv/` 的主版本，不必分别改两份。

## 整理与发布

```sh
# 预览归档清单
ruby tools/organize_workspace.rb
# 执行归档
ruby tools/organize_workspace.rb --apply
```

文件保留在 `.local/archive/`，不永久删除，恢复方式见 [目录整理说明](docs/workspace.md)。论文源码、`.bib`、`.bbl`、模板依赖、插图和正式 PDF 均保留。`papers/nips/` 匿名审稿 PDF 继续保持本地忽略状态。

构建后查看 `git diff`，仅提交相关源码和发布文件。构建脚本不执行 Git 暂存、提交或推送。推送 `main` 后由现有 GitHub Pages 流程发布。

项目基于 [academic-homepage](https://github.com/luost26/academic-homepage)。原文档保存在 [docs/template-readme.md](docs/template-readme.md)，许可证保留在 `LICENSE`。
