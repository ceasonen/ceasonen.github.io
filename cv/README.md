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

网站数据与 CV 不自动互转，身份、日期、成绩、排名和论文状态变化需同步修改。当前均分 92/100、GPA 4.70（不添加未确认的满分制）、排名 2/85。

主 CV 第一页是教育、Main Interests、三篇已录用论文、四篇 Preprint、实习和学术服务；第二页根据本地论文逐项介绍全部七项研究，再列奖项与技能。Preprint 条目保留研究方向代称，不公开私人稿件真题目、作者、独有方法名称、具体结果或下载链接。研究介绍使用稿件支持的概括；已录用论文的定量结果需保留数据集和评估范围。

`cheng-chen-cv-legacy` 仅为历史样式参考，不作为当前事实的维护入口；网站默认链接及中英文主 CV 是正式版本。
