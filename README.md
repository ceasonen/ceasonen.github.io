# Cheng Chen · 网站维护入口

线上主页：https://ceasonen.github.io/

**改网站只进 `site/`，改简历只进 `cv/`。根目录 HTML 和 `assets/` 是自动生成的发布副本，不要直接编辑。**

## 从这里开始

1. 在 VS Code / Cursor 中选择“文件 → 从文件打开工作区”，打开 [website.code-workspace](website.code-workspace)。左侧按网站、CV、论文、证书分组，不显示根目录发布副本。
2. 按下表找到文件，修改后在根目录运行 `ruby tools/website.rb build`。工作区也提供“网站：构建并检查”任务。

| 想改什么 | 只改这里 |
| --- | --- |
| 身份、联系方式、简介、教育 | [site/_data/profile.yml](site/_data/profile.yml) |
| Research Areas | [site/_data/research.yml](site/_data/research.yml) |
| Intern 经历、日期、校徽 | [site/_data/internships.yml](site/_data/internships.yml) |
| Reviewer | [site/_data/service.yml](site/_data/service.yml) |
| Highlights 奖项 | [site/_data/highlights.yml](site/_data/highlights.yml) |
| 精选 GitHub 项目 | [site/_data/projects.yml](site/_data/projects.yml) |
| 添加或修改论文 | [site/_publications/](site/_publications/)（每篇一个文件） |
| 添加新闻 | [site/_news/](site/_news/)（每条一个文件） |
| 导航栏 | [site/_data/navigation.yml](site/_data/navigation.yml) |
| 首页板块顺序 | [site/index.html](site/index.html) |
| 配色、字体、间距 | [site/assets/css/global.css](site/assets/css/global.css) |
| 头像、校徽、论文封面 | [site/assets/images/](site/assets/images/) |
| 英文 / 中文主 CV | [cv/cheng-chen-cv.tex](cv/cheng-chen-cv.tex) / [cv/cheng-chen-cv-zh.tex](cv/cheng-chen-cv-zh.tex) |

## 常用命令

```sh
ruby tools/website.rb build    # 生成网站 + 检查链接及内容
ruby tools/website.rb preview  # 预览 http://127.0.0.1:4000，Ctrl+C 停止
ruby tools/website.rb cv       # 编译所有 CV，更新 PDF
```

预览不是自动热更新；修改后在另一个终端运行 `build`，再刷新浏览器。脚本不自动提交或推送。论文条目示例和发布步骤见 [详细修改指南](docs/editing-guide.md)。

## 文件放哪里

| 目录 | 用途 |
| --- | --- |
| `site/` | 唯一网站源码（原 `academic-homepage/` 已迁到这里） |
| `cv/` | 唯一简历及个人材料源文件、正式 PDF |
| `papers/` | 论文原稿、模板与配套材料；不是主页论文列表的编辑入口 |
| `awards/` | 奖状与证书文件 |
| `docs/`、`tools/`、`tests/` | 维护指南、工具、自动检查 |
| `.build/` | 自动构建产物、LaTeX 日志；不提交 |
| `.local/` | 私有在审稿件与可恢复归档；不提交 |

根目录发布副本保留是为了兼容当前 GitHub Pages 设置及原有网址。不要另建第二套源码，也不要将整个仓库作为本地网页服务器根目录。归档和恢复见 [目录说明](docs/workspace.md)。

项目基于 [academic-homepage](https://github.com/luost26/academic-homepage)，原模板文档保存在 [docs/template-readme.md](docs/template-readme.md)，许可证保留。
