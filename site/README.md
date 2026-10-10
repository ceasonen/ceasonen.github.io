# 网站源码：平时在这里改

全部公开内容集中在 `index.html`，顶部导航跳转到同一页的板块。CV 在 `../cv/` 单独维护。根目录的 HTML 是生成副本，不要直接编辑。

| 想改什么 | 修改位置 |
| --- | --- |
| 简介、联系方式、教育背景 | `_data/profile.yml` |
| 研究方向 | `_data/research.yml` |
| 实习单位、日期、校徽 | `_data/internships.yml` |
| 审稿服务 | `_data/service.yml` |
| 项目 | `_data/projects.yml` |
| 奖项 | `_data/highlights.yml` |
| 论文 | `_publications/`，一篇一个文件 |
| 新闻 | `_news/`，一条一个文件 |
| 导航及定位 | `_data/navigation.yml`，链接格式 `/#section-id` |
| 板块顺序 | `index.html` |
| 实习、项目、论文布局 | `_includes/sections/` |
| 外壳、侧栏导航 | `_layouts/single.html`、`index.html` |
| 字体、颜色、间距、手机布局 | `assets/css/global.css` |
| 头像、校徽、论文主图 | `assets/images/` |

`publications.html`、`projects.html`、`intern.html`、`news.html`、`awards.html` 仅保留旧地址跳转，不是内容编辑入口。旧版 `_includes/widgets/` 中只有作者列表用于新主页，其余为历史模板。

从仓库根目录运行 `ruby tools/website.rb build`，预览使用 `ruby tools/website.rb preview`。原 `academic-homepage/` 路径已停用，勿重新创建。详细说明见 `../docs/editing-guide.md`。
