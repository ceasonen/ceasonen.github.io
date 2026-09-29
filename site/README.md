# 网站源码：平时在这里改

原 `academic-homepage/` 已整体迁到这里，请关闭旧路径标签，**不要在旧路径重新创建文件**。

- `_data/`：个人资料、研究方向、实习、审稿服务、Highlights、导航及显示设置。
- `_publications/`：一篇论文一个 `.md`，首页与 Publications 共用。
- `_news/`：一条新闻一个 `.md`。
- `assets/images/`：头像、校徽、论文封面；`assets/css/global.css`：样式。
- `index.html` 等：调整板块顺序和页面结构，日常内容优先改数据文件。
- `_includes/`、`_layouts/`：模板，通常不用改。

回到仓库根目录运行 `ruby tools/website.rb build`。CV 在 `../cv/`，不要复制进本目录。

操作示例见 [修改指南](../docs/editing-guide.md)，推荐打开根目录 [website.code-workspace](../website.code-workspace)。
