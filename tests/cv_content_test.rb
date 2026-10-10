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
    ["全国大学生数学建模竞赛，上海市三等奖（2025），队长",
     "全国大学生统计建模大赛，上海市三等奖（2025），队长"].each do |award|
      assert_includes chinese, award
    end
  end
end
