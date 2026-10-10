require "minitest/autorun"
require "nokogiri"
require "yaml"
require "open3"

class PageFocusTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def page(name)
    path = File.join(ROOT, name)
    assert File.file?(path), "Missing published page: #{name}"
    Nokogiri::HTML(File.read(path))
  end

  def test_projects_have_verified_repositories_and_specific_descriptions
    doc = page("projects.html")
    cards = doc.css(".project-card")
    assert_equal 4, cards.length
    %w[deep-research offer-pilot hlstrack2025-44686 research-skills].each do |repo|
      assert doc.at_css(".project-card a[href='https://github.com/ceasonen/#{repo}']"), repo
    end
    cards.each do |card|
      refute_empty card.at_css("h2").text.strip
      assert_operator card.css("li").length, :>=, 2
    end
    assert_includes doc.text, "Prototype"
    assert_includes doc.text, "Curated toolkit"
  end

  def test_secondary_pages_have_distinct_content_and_no_repeated_bio
    %w[publications.html projects.html intern.html news.html awards.html].each do |name|
      doc = page(name)
      assert_nil doc.at_css(".sidebar-bio"), name
      refute_nil doc.at_css("nav a[href='/projects']"), name
      next if name == "publications.html"
      assert_empty doc.css(".publication-item"), "Paper cards belong on Home and Publications: #{name}"
    end
    highlights = page("awards.html")
    assert_includes highlights.text, "Academic Service"
    assert_includes highlights.text, "Honors and Awards"
    assert_nil page("projects.html").at_css(".award-records")
  end

  def test_home_provides_short_project_preview_before_papers
    doc = page("index.html")
    assert_equal 2, doc.css(".project-preview").length
    assert doc.at_css("a[href='/projects']")
    assert_operator doc.to_html.index('id="projects"'), :<, doc.to_html.index('class="publication-item')
  end

  def test_main_cvs_are_two_pages_with_papers_but_no_website_projects
    %w[cheng-chen-cv cheng-chen-cv-zh].each do |name|
      pdf = File.join(ROOT, "cv/#{name}.pdf")
      info, status = Open3.capture2e("pdfinfo", pdf)
      assert status.success?, info
      assert_match(/^Pages:\s+2\s*$/, info, name)
      text, status = Open3.capture2e("pdftotext", pdf, "-")
      assert status.success?, text
      %w[IJCNN AAAI ICLR].each { |term| assert_includes text, term }
      ["AutoSearch", "OfferPilot", "FPGA Algorithm Optimization", "Research Skills", "精选软件与工程项目"].each do |term|
        refute_includes text, term
      end
      assert_includes text, "2/85"
    end
  end
end
