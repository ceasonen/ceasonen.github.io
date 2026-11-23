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

主 CV 第一页是教育、Main interests、三篇已发表论文、紧接其后的 Preprint、实习和荣誉与奖项；论文列表只列题目、作者、状态及可公开的链接。第二页介绍五项研究，再列专业能力与学术服务。研究经历优先突出图像编辑与多模态理解/生成相关工作。CINEMA 为预印本，已投稿 CVPR 2027，按用户确认的九位作者顺序署名；Follow Me If You Can 作为研究项目展示，作者为 Cheng Chen、Yi Xu、Wenzhuo Lei，不展示拒稿和评审分数。不恢复其他已移除稿件及投稿新闻，也不提供匿名审稿 PDF 下载。英文小标题使用句首大写；研究经历沿用完整正式题目。定量结果需保留数据集与评估范围。中文实习单位使用「香港科技大学（广州）」，英文使用「HKUST-GZ」。

中英文主 CV 完整列出主页 `site/_data/highlights.yml` 中的八项奖项，按时间从新到旧排列，跨学年以结束年份、开始年份依次降序。奖项后的 `#` 表示 Project Lead／项目负责人。照片版继续保留精选奖项。

公牛奖学金是企业奖学金，统一命名为 BULL Scholarship／公牛奖学金，不加 Tongji University／同济大学前缀。展示 2025--2026 学年，英文括注为 “CEIE's highest-tier first-class scholarship”，中文为“电信学院最高等级一等奖学金”，不展示金额；News 日期为动态发布时间。等级和个人获奖信息以用户确认为依据，不据类似基金公告改名为“国际交流奖学金”。

中英文主简历与照片版均用 XeLaTeX 编译，英文正文使用 Computer Modern Unicode；中文正文使用宋体。编译机器须安装这些字体。

`cheng-chen-cv-legacy` 仅为历史样式参考，不作为当前事实的维护入口；网站默认链接及中英文主 CV 是正式版本。
