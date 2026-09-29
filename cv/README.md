# CV 与个人材料

只在此目录维护 LaTeX 源码。网站导航默认下载 `cheng-chen-cv.pdf`。

| 文件名（省略扩展名） | 用途 |
| --- | --- |
| `cheng-chen-cv` | 英文主简历，网站默认 CV |
| `cheng-chen-cv-zh` | 中文主简历 |
| `cheng-chen-resume-photo-zh` | 中文照片版 |
| `cheng-chen-personal-statement-zh` | 中文个人陈述 |
| `cheng-chen-additional-profile-zh` | 其他个人经历与特长 |
| `cheng-chen-cv-legacy` | 旧版英文样式参考，不是默认下载 |

改 `.tex` 后从根目录运行：

```sh
ruby tools/website.rb cv cheng-chen-cv cheng-chen-cv-zh
```

不加文档名则编译全部。正式 PDF 在此目录，辅助文件和日志在 `.build/cv/`；legacy PDF 只放 `.build/cv/cheng-chen-cv-legacy/`。`me.png` 是照片，`index.html` 是 `/cv/` 的兼容入口。

网站数据与 CV 不自动互转，身份、日期、排名和论文状态变化需同步修改。不要将私有在审稿的真实题目、作者、具体方法或下载链接写进公开 CV。
