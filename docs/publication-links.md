# 论文公开链接核验

核验日期：2026-10-11。只添加题目、作者与内容均匹配的公开论文页面，不用相似研究、搜索结果页或匿名代码仓库代替论文链接。

| 论文 | 来源页面 | 网站和 CV 直达 PDF |
| --- | --- | --- |
| OV-OrthKD / If You Hear It, Help Find It | [来源](https://arxiv.org/abs/2609.23376) | [PDF](https://arxiv.org/pdf/2609.23376) |
| OrthKD | [来源](https://arxiv.org/abs/2607.25545) | [PDF](https://arxiv.org/pdf/2607.25545) |
| DeepYOLO / Enabling Visual Reasoning in Text-Only LLMs via Symbolic Scene Descriptions | [来源](https://www.researchgate.net/publication/410953742_Enabling_Visual_Reasoning_in_Text-Only_LLMs_via_Symbolic_Scene_Descriptions)（用户提供，已核验） | [PDF](https://ceasonen.github.io/assets/papers/deepyolo-ijcnn-2026.pdf) |

两个 arXiv PDF 地址均返回 HTTP 200 / `application/pdf`，无需下载论文。ResearchGate 提供的直链存在 HTTP 403 访问验证，因此 IJCNN 使用本地已有公开论文 `papers/ijcnn/main.pdf` 的明确发布副本（约 1.1 MB），题目、五位作者及 DeepYOLO 摘要与作者上传页面一致。发布文件只放 `site/assets/papers/`，不公开整个 `papers/` 工作目录。链接可见文字统一为 `[PDF]`。

对四篇 Preprint 按完整题目、题目短语、作者与 arXiv 域名组合检索，尚未定位到可靠匹配的公开论文页面，因此不生成链接，也不上传本地稿件。找到链接后需同时更新 `site/_publications/` 与 `cv/` 的对应条目。

作者顺序仍保持用户此前明确指定的 CV / 主页顺序；OV-OrthKD 的 arXiv 元数据目前列 Yi Xu、Cheng Chen、Wenzhuo Lei，与主页前两位共同一作的展示顺序不同，本次仅加链接，没有擅自改作者排序。

CV 字体参考：[Liming Lu 的 CV](https://elemmire1.github.io/static/assets/CV.pdf)。参考文件嵌入 Computer Modern 系列（CMR / CMBX / CMTI）；本地 XeLaTeX 使用同一设计的 Computer Modern Unicode OpenType（`cmunrm.otf`、`cmunbx.otf`、`cmunti.otf`、`cmunbi.otf`），保证中文兼容和字体嵌入。
