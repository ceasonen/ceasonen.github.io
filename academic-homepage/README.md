# 网站源码

这里存放 Jekyll 页面、数据、模板和资源。操作命令见 [根目录 README](../README.md)。

- 在此目录编辑页面、数据、模板以及 assets/。
- 从仓库根目录运行 `ruby tools/build_site.rb`，生成到 `.build/site/` 并更新发布页面。
- CV 和论文只在仓库根目录的 cv/、papers/ 维护，旧镜像已本地归档。
- 使用 `ruby tools/build_cv.rb` 编译 CV，所有临时文件进入 .build/cv/。

原模板文档见 [docs/template-readme.md](../docs/template-readme.md)。
