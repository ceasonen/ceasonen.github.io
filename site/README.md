# 网站源码：平时在这里改

原 `academic-homepage/` 已整体迁到这里，请关闭旧路径标签，**不要在旧路径重新创建文件**。

- `_data/`：个人资料、研究方向、实习、审稿服务、精选项目、Highlights、导航及显示设置。
- `_publications/`：一篇论文一个 `.md`，首页与 Publications 共用。
- `_news/`：一条新闻一个 `.md`。
- `assets/images/`：头像、校徽、论文封面；`assets/css/global.css`：样式。
- `index.html` 等：调整板块顺序和页面结构，日常内容优先改数据文件。
- `_includes/`、`_layouts/`：模板，通常不用改。

回到仓库根目录运行 `ruby tools/website.rb build`。CV 在 `../cv/`，不要复制进本目录。

操作示例见 [修改指南](../docs/editing-guide.md)，推荐打开根目录 [website.code-workspace](../website.code-workspace)。

## 页面分工

- Home：简短个人简介、研究方向、服务、最近动态、两个项目预览及论文。
- Publications：完整论文列表；不再复制到 Highlights。
- Projects：精选软件、工程项目和研究工具，内容统一维护在 `_data/projects.yml`；`featured: true` 控制首页预览。
- Intern：实习单位和时间线。
- News：按时间排列的简短动态，不展开论文或项目卡片。
- Highlights：奖项和学术服务。
- CV：中英文主简历均为两页，源码仍在 `../cv/`。
