require "minitest/autorun"
require "yaml"
require "date"

class CvContentTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def source(name)
    File.read(File.join(ROOT, "cv/#{name}.tex"))
  end

  def test_current_cvs_use_the_precise_percentage_score
    %w[cheng-chen-cv cheng-chen-cv-zh cheng-chen-resume-photo-zh].each do |name|
      assert_includes source(name), '\textbf{92.02/100}', name
      refute_includes source(name), '\textbf{92/100}', name
      assert_includes source(name), '\textbf{4.70}', name
    end
  end

  def test_cv_interests_match_the_current_homepage_introduction
    profile = YAML.safe_load(File.read(File.join(ROOT, "site/_data/profile.yml")))
    interests = profile.fetch("short_bio").scan(/<p>(.*?)<\/p>/m).last.first.strip
    assert_includes source("cheng-chen-cv"), interests
    chinese = "我探索以简洁高效的方法提升 AI 能力，研究如何改进模型算法及其训练与部署系统。目前尤其关注多模态大模型、图像/视频生成、AI 基础设施与面向具身智能的强化学习。"
    %w[cheng-chen-cv-zh cheng-chen-resume-photo-zh].each do |name|
      assert_includes source(name), chinese, name
    end
    assert_includes source("cheng-chen-resume-photo-zh"), "目前为同济大学通信工程本科生，预计于 2027 年 6 月毕业。"
  end

  def test_all_cv_sources_omit_future_phd_claims
    %w[cheng-chen-cv cheng-chen-cv-zh cheng-chen-resume-photo-zh
       cheng-chen-additional-profile-zh cheng-chen-personal-statement-zh
       cheng-chen-cv-legacy].each do |name|
      refute_match(/ph\.?d|incoming|chinese academy of sciences|kaiqi huang|博士|自动化研究所|黄凯奇/i,
                   source(name), name)
    end
    assert_match(/\\cvsection\{Education\}\s*\\textbf\{Tongji University\}/,
                 source("cheng-chen-cv"))
    assert_match(/\\cvsection\{教育背景\}\s*\\textbf\{同济大学\}/,
                 source("cheng-chen-cv-zh"))
  end

  def test_photo_cv_uses_the_correct_undergraduate_graduation_year
    photo = source("cheng-chen-resume-photo-zh")
    assert_includes photo, "2023.09 至 2027.06（预计）"
    refute_includes photo, "2023.09 至 2026.06（预计）"
  end

  def test_all_research_entries_match_the_full_publication_titles
    papers = Dir[File.join(ROOT, "site/_publications/**/*.md")].map do |path|
      YAML.safe_load(File.read(path).split("---", 3)[1], permitted_classes: [Date, Time])
    end.sort_by { |paper| paper.fetch("rank") }
    assert_equal 3, papers.length
    titles = papers.map { |paper| paper.fetch("title") }
    %w[cheng-chen-cv cheng-chen-cv-zh].each do |name|
      assert_equal titles, source(name).scan(/^\\researchentry\{([^}]+)\}/).flatten, name
    end
  end

  def test_cv_section_headings_use_sentence_case
    assert_equal ["Education", "Main interests", "Publications", "Research internships",
                  "Awards and honors", "Technical skills", "Research experience", "Academic service"],
                 source("cheng-chen-cv").scan(/^\\cvsection\{([^}]+)\}/).flatten
    %w[cheng-chen-cv-zh cheng-chen-resume-photo-zh].each do |name|
      assert_includes source(name), "{Main interests}", name
      refute_includes source(name), "{MAIN INTERESTS}", name
    end
  end

  def test_main_cv_section_headings_are_slightly_larger
    %w[cheng-chen-cv cheng-chen-cv-zh].each do |name|
      heading = source(name).lines.find { |line| line.start_with?('\\newcommand{\\cvsection}') }
      assert_includes heading, '\\fontsize{13}{15.5}\\selectfont\\bfseries', name
    end
  end

  def test_main_cvs_cover_every_award_shown_on_the_homepage
    awards = YAML.safe_load(File.read(File.join(ROOT, "site/_data/highlights.yml"))).fetch("awards")
    english = source("cheng-chen-cv").split('\\cvsection{Awards and honors}', 2).last.split('\\cvsection{Technical skills}', 2).first
    chinese = source("cheng-chen-cv-zh").split('\\cvsection{荣誉与奖项}', 2).last.split('\\cvsection{专业能力}', 2).first
    assert_equal awards.length, english.scan(/^\\item /).length
    assert_equal awards.length, chinese.scan(/^\\item /).length
    awards.each { |award| assert_includes english, award.fetch("name") }
    assert_includes english, '\# Project Lead'
    assert_equal 5, english.scan('\\textsuperscript{\\#}').length
    refute_match(/\)\\textsuperscript\{\\#\}\./, english)
    refute_includes english, "Team Captain"
    refute_includes english, "FPGA Track"
    assert_includes chinese, '\# 项目负责人'
    assert_equal 5, chinese.scan('\\textsuperscript{\\#}').length
    refute_match(/）\\textsuperscript\{\\#\}。/, chinese)
    refute_includes chinese, "队长"
    refute_includes chinese, "FPGA 赛道"
    ["全国大学生数学建模竞赛，省级三等奖（2025）",
     "全国大学生统计建模大赛，省级三等奖（2025）"].each do |award|
      assert_includes chinese, award
    end
  end

  def test_internship_display_name_is_short_in_current_cvs
    %w[cheng-chen-cv cheng-chen-cv-legacy].each do |name|
      assert_includes source(name), "HKUST-GZ", name
      refute_includes source(name), "Hong Kong University of Science and Technology (Guangzhou)", name
    end
    %w[cheng-chen-cv-zh cheng-chen-resume-photo-zh].each do |name|
      assert_includes source(name), "香港科技大学（广州）", name
      refute_includes source(name), "HKUST-GZ", name
    end
  end

  def test_main_cvs_label_verified_paper_roles_and_review_stage
    english = source("cheng-chen-cv")
    chinese = source("cheng-chen-cv-zh")
    [english, chinese].each do |cv|
      assert_includes cv, '\href{https://github.com/ScottBlizzard/OV-OrthKD}{[Project]}'
      assert_includes cv, '\href{https://github.com/ScottBlizzard/orthkd-dr-screening}{[Code]}'
      assert_includes cv, 'Yi Xu*\textsuperscript{‡}, \textbf{Cheng Chen*}, Wenzhuo Lei\textsuperscript{†}'
      assert_includes cv, 'Yi Xu*\textsuperscript{†}, \textbf{Cheng Chen*}\textsuperscript{‡}, Mufan Cao'
      assert_includes cv, '\textbf{Cheng Chen}\textsuperscript{†‡}'
      refute_match(/Preprints|预印本|Cheng Chen and collaborators|submitted|Phase 2|第二阶段|已投稿/, cv)
    end
    assert_includes english, 'HKUST-GZ'
    assert_includes chinese, '香港科技大学（广州）'
    assert_includes english, 'Reviewer:} ICLR(2027), AAAI(2027), ICME(2026), IJCNN(2026,2027), PRCV(2026).'
    assert_includes chinese, '审稿人：}ICLR(2027)、AAAI(2027)、ICME(2026)、IJCNN(2026,2027)、PRCV(2026)。'
    assert_equal 0, english.scan('{2026; lead and corresponding author}').length
    assert_equal 0, chinese.scan('{2026；项目负责人、通讯作者}').length
  end

  def test_photo_cv_labels_verified_paper_roles_and_review_stage
    photo = source("cheng-chen-resume-photo-zh")
    assert_includes photo, 'OV-OrthKD'
    assert_includes photo, '项目负责人：Yi Xu；通讯作者：Wenzhuo Lei'
    assert_includes photo, '项目负责人：Cheng Chen；通讯作者：Yi Xu'
    assert_includes photo, 'IJCNN 2026 · 项目负责人、通讯作者 · 已发表'
    refute_match(/预印本|Cheng Chen 等人|第二阶段|已投稿/, photo)
    assert_includes photo, '香港科技大学（广州）'
    assert_includes photo, 'ICLR(2027)、AAAI(2027)、ICME(2026)；\\'
    assert_includes photo, 'IJCNN(2026,2027)、PRCV(2026)。'
  end

  def test_cv_modeling_prizes_use_provincial_labels
    english = source("cheng-chen-cv")
    chinese = source("cheng-chen-cv-zh")
    assert_equal 2, english.scan("Provincial Third Prize").length
    assert_equal 2, chinese.scan("省级三等奖").length
    refute_match(/Shanghai (First|Second|Third) Prize/, english)
    refute_match(/上海市?[一二三]等奖/, chinese)
  end

  def test_first_page_lists_papers_without_repeating_research_summaries
    %w[cheng-chen-cv cheng-chen-cv-zh].each do |name|
      first_page = source(name).split('\\newpage', 2).first
      refute_includes first_page, '\\papersummary', name
      papers = first_page.split('\\end{enumerate}', 2).first
      assert_equal 3, papers.scan(/^\\item /).length, name
      refute_match(/^\\researchentry\{/, first_page, name)
    end
  end

  def test_technical_skills_are_separate_concise_and_consistent
    english = source("cheng-chen-cv")
    chinese = source("cheng-chen-cv-zh")
    photo = source("cheng-chen-resume-photo-zh")

    assert_match(/\\textbf\{Programming:\} Python, C\/C\+\+, Verilog\.\\\\\n\\textbf\{Machine learning frameworks:\} PyTorch, JAX\.\\\\/, english)
    assert_match(/\\textbf\{编程：\}Python、C\/C\+\+、Verilog。\\\\\n\\textbf\{机器学习框架：\}PyTorch、JAX。\\\\/, chinese)
    assert_includes english, 'ROS 2'
    refute_includes english, '(learning)'
    assert_includes chinese, 'ROS 2'
    refute_includes chinese, '学习中'
    assert_includes photo, '\\textbf{框架：}PyTorch，JAX\\par'
    assert_includes photo, 'ROS 2'
    refute_includes photo, '学习中'
    assert_includes english, '\\textbf{Foundations:} Machine learning, deep learning, algorithms, linear algebra, probability, optimization, and digital signal processing.'
    assert_includes chinese, '\\textbf{基础：}机器学习、深度学习、算法、线性代数、概率论、最优化与数字信号处理。'
    assert_includes photo, '\\textbf{基础：}机器学习、深度学习、算法、线性代数、概率论、最优化、数字信号处理'
  end

  def test_provincial_second_prize_precedes_provincial_third_prizes
    awards = YAML.safe_load(File.read(File.join(ROOT, "site/_data/highlights.yml"))).fetch("awards")
    assert_operator awards.index { |award| award.fetch("prize") == "Provincial Second Prize" }, :<,
                    awards.index { |award| award.fetch("prize") == "Provincial Third Prize" }
    english = source("cheng-chen-cv")
    chinese = source("cheng-chen-cv-zh")
    assert_operator english.index("Provincial Second Prize"), :<, english.index("Provincial Third Prize")
    assert_operator chinese.index("省级二等奖"), :<, chinese.index("省级三等奖")
  end
end
