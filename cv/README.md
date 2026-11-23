# CV 与个人材料

只在此目录维护 LaTeX 源码。网站导航默认下载 `cheng-chen-cv.pdf`。

| 文件名（省略扩展名） | 用途 |
| --- | --- |
| `cheng-chen-cv` | 两页英文主简历，网站默认 CV |
| `cheng-chen-cv-zh` | 两页中文主简历 |
| `cheng-chen-resume-photo-zh` | 中文照片版 |
| `cheng-chen-personal-statement-zh` | 中文个人陈述 |
| `cheng-chen-additional-profile-zh` | 其他个人经历与特长 |
| `cheng-chen-cv-legacy` | 旧版英文样式参考，不是默认下载 |

改 `.tex` 后从根目录运行：

```sh
ruby tools/website.rb cv cheng-chen-cv cheng-chen-cv-zh
```

不加文档名则编译全部。正式 PDF 在此目录，辅助文件和日志在 `.build/cv/`；legacy PDF 只放 `.build/cv/cheng-chen-cv-legacy/`。`me.png` 是照片，`index.html` 是 `/cv/` 的兼容入口。

网站数据与 CV 不自动互转，身份、日期、成绩、排名和论文状态变化需同步修改。当前均分 92.02/100、GPA 4.70（不添加未确认的满分制）、排名 2/85。

主 CV 第一页是教育、Main interests、三篇已发表论文、紧接其后的 Preprint、实习和荣誉与奖项。Preprint 沿用论文的编号、题目、作者、状态格式，从 4 开始编号。CINEMA 已投稿 CVPR 2027，按九位作者顺序署名；Cheng Chen 为第一作者及项目负责人（‡），Zhiyuan Cao 为通讯作者（†）。第二页介绍五项研究，再列专业能力与学术服务。“统一多模态模型适配与评测”作为项目介绍，不展示旧论文题目、论文式作者行、投稿经历或评审分数。其他移除稿件不恢复，匿名审稿 PDF 不公开下载。定量结果保留数据集与评估范围。中文实习单位使用「香港科技大学（广州）」，英文使用「HKUST-GZ」。

中英文主 CV 完整列出主页 `site/_data/highlights.yml` 中的八项奖项。按用户确认，最新的公牛奖学金排第一，其余按时间从新到旧排列。奖项后的 `#` 表示 Project Lead／项目负责人。照片版保留精选奖项。

公牛奖学金是企业奖学金，统一命名为 BULL Scholarship／公牛奖学金，不加学校前缀。展示 2025--2026 学年，英文括注保留 “CEIE's highest-tier first-class scholarship”，不展示金额；News 日期为动态发布时间。Education 定义 CEIE 为 College of Electronic and Information Engineering／电子与信息工程学院，英文名按[学院官网](https://see-en.tongji.edu.cn/about_Us/Introduction_to_CEIE.htm)。等级与个人获奖信息以用户确认为依据。

中英文主简历与照片版均用 XeLaTeX 编译，英文正文使用 Computer Modern Unicode；中文正文使用宋体。编译机器须安装这些字体。

CINEMA 的研究介绍结合正文及本地补充材料 A、L--N 节。当前定量例子来自补充材料 Table S4 的 PeRFlow 对照：PIE100 控制集、82 个背景有效样本、99 次预热后的计时编辑；原生与 CINEMA 均为 8 次去噪网络调用、0.927 秒完整编辑时延中位数，背景 PSNR 为 28.97 与 30.94 dB。配对交互的精确复合和最小位移性质不等同于整个神经生成过程的精确性或任务完成保证。不得混用正文与补充实验的计时协议，匿名补充 PDF 只保留本地。

`cheng-chen-cv-legacy` 仅为历史样式参考，不作为当前事实的维护入口；网站默认链接及中英文主 CV 是正式版本。
