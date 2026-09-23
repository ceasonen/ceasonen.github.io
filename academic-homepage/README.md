# 网站源码

这里存放 Jekyll 页面、数据、模板和资源。操作命令见 [根目录 README](../README.md)。

- 在此目录编辑页面、数据、模板以及 assets/。
- 从仓库根目录运行 `ruby tools/build_site.rb`，生成到 `.build/site/` 并更新发布页面。
- cv/、papers/ 为历史镜像，主版本在仓库根目录，网站构建会排除它们。
- 使用 `ruby tools/build_cv.rb` 编译 CV，并同步已有 CV 镜像。

原模板文档见 [docs/template-readme.md](../docs/template-readme.md)。
