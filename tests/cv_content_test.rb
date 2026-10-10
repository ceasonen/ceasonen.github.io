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
end
