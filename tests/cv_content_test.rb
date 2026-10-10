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
    chinese = "目前主要研究如何用更简洁、优雅的方法提升模型能力，关注方向包括但不限于多模态大语言模型、视频与图像生成，以及具身智能。"
    %w[cheng-chen-cv-zh cheng-chen-resume-photo-zh].each do |name|
      assert_includes source(name), chinese, name
    end
    assert_includes source("cheng-chen-resume-photo-zh"), "目前为同济大学通信工程本科生，预计于 2027 年 9 月在黄凯奇老师指导下攻读博士。"
  end

  def test_all_research_entries_match_the_full_publication_titles
    papers = Dir[File.join(ROOT, "site/_publications/**/*.md")].map do |path|
      YAML.safe_load(File.read(path).split("---", 3)[1], permitted_classes: [Date, Time])
    end.sort_by { |paper| paper.fetch("rank") }
    assert_equal 7, papers.length
    titles = papers.map { |paper| paper.fetch("title") }
    %w[cheng-chen-cv cheng-chen-cv-zh].each do |name|
      assert_equal titles, source(name).scan(/^\\researchentry\{([^}]+)\}/).flatten, name
    end
  end

  def test_cv_section_headings_use_sentence_case
    assert_equal ["Education", "Main interests", "Publications", "Preprints", "Research internships",
                  "Academic service", "Research experience", "Awards and honors", "Technical skills"],
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
    assert_equal 5, english.scan("Team Captain").length
    ["全国大学生数学建模竞赛，省级三等奖（2025），队长",
     "全国大学生统计建模大赛，省级三等奖（2025），队长"].each do |award|
      assert_includes chinese, award
    end
  end

  def test_cv_modeling_prizes_use_provincial_labels
    english = source("cheng-chen-cv")
    chinese = source("cheng-chen-cv-zh")
    assert_equal 2, english.scan("Provincial Third Prize").length
    assert_equal 2, chinese.scan("省级三等奖").length
    refute_match(/Shanghai (First|Second|Third) Prize/, english)
    refute_match(/上海市?[一二三]等奖/, chinese)
  end

  def test_first_page_explains_each_paper_with_a_short_summary
    %w[cheng-chen-cv cheng-chen-cv-zh].each do |name|
      first_page = source(name).split('\\newpage', 2).first
      summaries = first_page.scan(/^\\papersummary\{([^}]+)\}/).flatten
      assert_equal 7, summaries.length, name
      summaries.each do |summary|
        refute_empty summary.strip, name
        assert_operator summary.length, :<=, 160, name
      end
    end
  end
end
