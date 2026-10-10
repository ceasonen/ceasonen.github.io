# WowPage 设计基础与当前改版

上游：[WD7ang/WowPage](https://github.com/WD7ang/WowPage)，MIT 授权。模板源码已按要求稀疏克隆到本地忽略目录 `.local/reference/WowPage/`；没有下载示例图片，也不把嵌套仓库发布到主页。

## 实际沿用的基础

- `assets/css/home.css`：白底、圆润正文、Permanent Marker 欢迎标题、浅灰 News 滚动框、12px 圆角实习卡片、柔和悬停阴影、论文筛选按钮。
- `_sass/_sidebar.scss` 与 `_includes/author-profile.html`：圆形头像、姓名与简介的层级、图标和社交链接的间距。
- `_sass/_variables.scss`：灰色正文、轻分隔线、约 70px 的顶部导航、侧栏 / 主内容双栏比例。
- `_pages/about.md`：论文主图 320 × 180px、作者斜体及会议配色、图文并排的论文展示。

当前样式在 `site/assets/css/global.css`，图标在 `site/_includes/widgets/icon.html`，并保留 MIT 声明 [wowpage-MIT.txt](licenses/wowpage-MIT.txt)。没有导入模板的示例人物、论文、奖项、分析脚本或不使用的页面。

## 在原版基础上的改进

- 正文保持原版圆润风格，改用本地托管的 Nunito 可变字体统一标题、正文、侧栏、奖项、论文和导航；通过 600–900 字重、颜色和留白分层，不再混用系统常规字体或手写字体。字体约 38 KB，许可证见 [nunito-OFL.txt](licenses/nunito-OFL.txt)。
- 论文主图恢复 320px 桌面宽度，窄屏采用图文上下布局；完整题目不会截断。
- 只保留一组七篇论文卡片，用 All Research / Publications / Preprints 筛选，不复制另一份论文列表。无 JavaScript 时默认仍能阅读全部七篇。
- 学术服务仍在最后，导航与页面板块顺序一致；手机菜单、键盘焦点与低动态偏好独立处理。
- 图标使用轻量内联 SVG，不依赖完整图标字体库。
- 奖项拆为奖级、比赛名称、年份和角色；全国一等奖使用一张浅玫瑰色通栏卡片，其余采用双列轻边框卡片，手机上自动单列。全部七项保留，比赛全称不追加括号缩写。
- News 合并重复的 ICLR 消息，保留一条三篇投稿汇总；论文链接统一标记 PDF，直接进入论文文件。学术服务以紧凑会议标签收尾，旧地址和 404 使用同一字体系统。
- 保持单一维护入口 `site/`；正式 CV 字体与内容不受主页改版影响。
- 教育卡片使用同济和国科大校徽，统一尺寸并完整显示，不再使用通用学位图标。国科大校徽 PNG（约 211 KB）来自 [校徽资源页](https://www.urongda.com/logos/4111014430)，图形与[国科大标识说明](https://www.ucas.ac.cn/zyxz/317e89147f454990bb5cf8df9724e1d8.htm)一致；同济复用已有校徽素材。校徽只用于说明教育经历，不改变博士培养单位的名称。
- 简介保留一段研究兴趣，删除重复的四项方向列表；英文 CV 与该段文字一致，中文版本同步对应内容。

截图及浏览器检查放在 `.build/preview/`，不提交 Git。日常维护仍见 [editing-guide.md](editing-guide.md)。
