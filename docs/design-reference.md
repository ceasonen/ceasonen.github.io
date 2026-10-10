# WowPage 设计基础与当前改版

上游：[WD7ang/WowPage](https://github.com/WD7ang/WowPage)，MIT 授权。模板源码已按要求稀疏克隆到本地忽略目录 `.local/reference/WowPage/`；没有下载示例图片，也不把嵌套仓库发布到主页。

## 实际沿用的基础

- `assets/css/home.css`：白底、圆润正文、Permanent Marker 欢迎标题、浅灰 News 滚动框、12px 圆角实习卡片、柔和悬停阴影、论文筛选按钮。
- `_sass/_sidebar.scss` 与 `_includes/author-profile.html`：圆形头像、姓名与简介的层级、图标和社交链接的间距。
- `_sass/_variables.scss`：灰色正文、轻分隔线、约 70px 的顶部导航、侧栏 / 主内容双栏比例。
- `_pages/about.md`：论文主图 320 × 180px、作者斜体及会议配色、图文并排的论文展示。

当前样式在 `site/assets/css/global.css`，图标在 `site/_includes/widgets/icon.html`，并保留 MIT 声明 [wowpage-MIT.txt](licenses/wowpage-MIT.txt)。没有导入模板的示例人物、论文、奖项、分析脚本或不使用的页面。

## 在原版基础上的改进

- 正文保持原版圆润风格；实习描述、论文作者和摘要使用清晰的常规字体，避免全页文字同样粗重。
- 论文主图恢复 320px 桌面宽度，窄屏采用图文上下布局；完整题目不会截断。
- 只保留一组七篇论文卡片，用 All Research / Publications / Preprints 筛选，不复制另一份论文列表。无 JavaScript 时默认仍能阅读全部七篇。
- 学术服务仍在最后，导航与页面板块顺序一致；手机菜单、键盘焦点与低动态偏好独立处理。
- 图标使用轻量内联 SVG，不依赖完整图标字体库。
- 保持单一维护入口 `site/`；正式 CV 字体与内容不受主页改版影响。

截图及浏览器检查放在 `.build/preview/`，不提交 Git。日常维护仍见 [editing-guide.md](editing-guide.md)。
