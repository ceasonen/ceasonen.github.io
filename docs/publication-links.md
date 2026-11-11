# 论文公开链接核验

最新核验日期：2026-11-11。只添加题目、作者与内容均匹配的公开论文页面，不用相似研究、搜索结果页或匿名代码仓库代替论文链接。

| 论文 | 来源页面 | 网站和 CV 直达 PDF |
| --- | --- | --- |
| OV-OrthKD / If You Hear It, Help Find It | [ACM DOI](https://doi.org/10.1145/3767308.3835302) | [PDF](https://arxiv.org/pdf/2609.23376) |
| OrthKD | [IJCAI 官方论文集](https://ijcai.org/proceedings/2026/774) | [正式 PDF](https://ijcai.org/proceedings/2026/0774.pdf) |
| DeepYOLO / Enabling Visual Reasoning in Text-Only LLMs via Symbolic Scene Descriptions | [IEEE Xplore](https://ieeexplore.ieee.org/document/11729294/) | [PDF](https://ceasonen.github.io/assets/papers/deepyolo-ijcnn-2026.pdf) |

2026-10-11 核验时，两个 arXiv PDF 地址均返回 HTTP 200 / `application/pdf`。ResearchGate 提供的直链存在 HTTP 403 访问验证，因此 IJCNN 使用本地已有公开论文 `papers/ijcnn/main.pdf` 的明确发布副本（约 1.1 MB），题目、五位作者及 DeepYOLO 摘要与作者上传页面一致。发布文件只放 `site/assets/papers/`，不公开整个 `papers/` 工作目录。链接可见文字统一为 `[PDF]`。2026-11-02 已将 OrthKD 的 PDF 改为正式论文集版本。

2026-11-09 根据用户要求，主页、各版 CV 与个人陈述撤下全部预印本条目及相关研究介绍，并移除投稿数量和审稿阶段新闻。当前只展示三篇已录用或发表论文；原条目保存在本地私有归档，不随网站发布。

2026-11-11 根据用户确认与正式出版记录，OV-OrthKD 的署名统一为 Yi Xu、Cheng Chen、Wenzhuo Lei；前两位保留共同第一作者标记，Cheng Chen 署名第二。保留此前确认的项目负责人及通讯作者标记。

CV 字体参考：[Liming Lu 的 CV](https://elemmire1.github.io/static/assets/CV.pdf)。参考文件嵌入 Computer Modern 系列（CMR / CMBX / CMTI）；本地 XeLaTeX 使用同一设计的 Computer Modern Unicode OpenType（`cmunrm.otf`、`cmunbx.otf`、`cmunti.otf`、`cmunbi.otf`），保证中文兼容和字体嵌入。

## IJCNN DOI 核验（2026-11-02）

IEEE 提交的 [Crossref 原始记录](https://api.crossref.org/works/10.1109/IJCNN69854.2026.11729294) 与论文完整题目及五位作者顺序一致：Wenzhuo Lei、Mufan Cao、Chaorong Ye、Yi Xu、Cheng Chen。终稿首页明确 Cheng Chen 为通讯作者；网站和中英文 CV 保留 † 通讯作者及原有 ‡ 项目负责人标记。

- 最终 DOI：[10.1109/IJCNN69854.2026.11729294](https://doi.org/10.1109/IJCNN69854.2026.11729294)。
- 出版社论文页面：[IEEE Xplore, document 11729294](https://ieeexplore.ieee.org/document/11729294/)。
- 会议全名：2026 International Joint Conference on Neural Networks (IJCNN)，页码 1–6。
- Crossref 的 published / published-print / issued 为 2026-06，仅精确到月；会议日期为 2026-06-22 至 2026-06-26。
- Crossref created 为 2026-10-19T19:14:25Z，这是 DOI 注册时间，不能替代正式发表日或 Xplore 上线日。
- 当前访问无法读取 IEEE Xplore 的 Date Added to IEEE Xplore，具体上线日期尚未核实，不写入主页或 CV。

本次同步论文源条目、生成首页及中英文 CV 源码，保留原 PDF 链接。

## 已录用论文版本复核（2026-11-02）

- **OrthKD**：已核实 [IJCAI 官方论文集页面](https://ijcai.org/proceedings/2026/774)、[正式 PDF](https://ijcai.org/proceedings/2026/0774.pdf) 和 [Crossref 记录](https://api.crossref.org/works/10.24963/ijcai.2026/774)。DOI 为 `10.24963/ijcai.2026/774`，页码 6958–6965；题目、三位作者顺序及研究内容一致。主页增加官方页面与 DOI，主 CV 和照片版替换 PDF 链接，主 CV 补正式页码。
- **DeepYOLO / IJCNN**：重新读取 IEEE 提交的 Crossref 记录，题目、五位作者和页码 1–6 均匹配。保留已拉取的 Xplore 与 DOI 链接；主 CV 补正式页码，照片版补 DOI。出版社 PDF 的稳定公开访问未核实，继续保留现有可直接阅读的 PDF。
- **OV-OrthKD / ACM MM**：2026-11-11 已核实 [ACM 提交的 Crossref 记录](https://api.crossref.org/works/10.1145/3767308.3835302) 和[作者仓库](https://github.com/ScottBlizzard/OV-OrthKD)。正式 DOI 为 `10.1145/3767308.3835302`，页码 12794–12802，published 日期为 2026-11-09；题目和三位作者顺序匹配。主页和各版 CV 补 DOI，中英文主 CV 补正式页码。ACM PDF 端点当前返回 HTTP 403，继续使用可直读的 arXiv PDF，不将访问验证页面标成 PDF 下载。

以上只更新有可靠来源的出版信息；未找到不代表尚未发表。保持用户指定的作者展示顺序及贡献标记，不根据检索猜测投稿结果。
