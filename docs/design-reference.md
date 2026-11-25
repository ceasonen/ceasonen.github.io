# 主页设计与素材

主页的维护入口是 `site/`。日常更新见 [editing-guide.md](editing-guide.md)。

- 首屏用带方格底的魔方照片、自我介绍和社交链接建立视觉重心。桌面用左侧标题列和右侧正文对齐各区块，手机改为单列。正文使用本地 Nunito，Caveat 用于 Writing 标题。
- 新闻默认显示最近四条。经历用较大的校徽呈现教育和实习，论文用原有研究图并保留筛选，项目和奖项采用留有对齐空间的行式布局。
- Writing 入口使用[《ちいかわ》动画官网提供的乌撒气图片](https://www.anime-chiikawa.jp/images/bg_top_usagi_01.png)。文章通过 `site/_posts/` 维护，并统一使用单栏阅读布局。
- 色调环用色相调整强调色、文字、分隔线和背景。浏览器在同一站点的主页与文章页之间沿用所选色调。初始色调和交互分别由 `site/assets/css/tone.css` 与 `site/assets/js/tone.js` 控制。

参考站的语言切换、经历时间线、论文分组和文章入口见 [Weidong Tang 的主页](https://wd7ang.github.io/)。主页早期布局采用 [WowPage](https://github.com/WD7ang/WowPage) 的结构，授权见 [MIT 许可证](licenses/wowpage-MIT.txt)。本地字体授权见 [Nunito](licenses/nunito-OFL.txt) 和 [Caveat](../site/assets/fonts/Caveat-OFL.txt)。
