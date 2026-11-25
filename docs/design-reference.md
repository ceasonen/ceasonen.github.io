# 主页设计与素材

主页的维护入口是 `site/`。日常更新见 [editing-guide.md](editing-guide.md)。

- 主页采用紧凑的单页布局。正文使用本地 Nunito，Caveat 仅用于自我介绍标题。导航顺序与正文一致，新闻默认显示最近四条。
- Writing 入口使用[《ちいかわ》动画官网提供的乌撒气图片](https://www.anime-chiikawa.jp/images/bg_top_usagi_01.png)。文章通过 `site/_posts/` 维护，并统一使用单栏阅读布局。
- 色调环用色相调整强调色、文字、分隔线和背景。浏览器在同一站点的主页与文章页之间沿用所选色调。初始色调和交互分别由 `site/assets/css/tone.css` 与 `site/assets/js/tone.js` 控制。

早期双栏布局与侧栏参考 [WD7ang/WowPage](https://github.com/WD7ang/WowPage)，授权见 [MIT 许可证](licenses/wowpage-MIT.txt)。本地字体授权见 [Nunito](licenses/nunito-OFL.txt) 和 [Caveat](../site/assets/fonts/Caveat-OFL.txt)。
