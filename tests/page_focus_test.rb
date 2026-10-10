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
    doc = page("index.html")
    cards = doc.css(".project-card")
    assert_equal 4, cards.length
    %w[deep-research offer-pilot hlstrack2025-44686 research-skills].each do |repo|
      assert doc.at_css(".project-card a[href='https://github.com/ceasonen/#{repo}']"), repo
    end
    cards.each do |card|
      refute_empty card.at_css("h3").text.strip
      assert_operator card.css("li").length, :>=, 2
    end
    assert_includes doc.text, "Prototype"
    assert_includes doc.text, "Curated toolkit"
  end

  def test_legacy_pages_redirect_to_home_sections
    {"publications" => "publications", "projects" => "projects", "intern" => "experience", "news" => "news", "awards" => "awards"}.each do |path, section|
      doc = page("#{path}.html")
      assert_equal "0; url=/##{section}", doc.at_css('meta[http-equiv="refresh"]')["content"]
      assert_empty doc.css(".publication-card, .project-card, .experience-card")
    end
  end

  def test_home_navigation_targets_sections_that_exist_once
    doc = page("index.html")
    doc.css(".section-nav a").each do |link|
      next if link["href"].end_with?(".pdf")
      assert link["href"].start_with?("/#"), link["href"]
      assert_equal 1, doc.css(link["href"].delete_prefix("/")).length
    end
    assert_equal 3, doc.css("#experience .experience-card").length
    assert_equal 4, doc.css("#projects .project-card").length
    assert_equal 7, doc.css("#publications .publication-card").length
    assert_operator doc.to_html.index('id="service"'), :<, doc.to_html.index('id="publications"')
    assert_operator doc.to_html.index('id="projects"'), :<, doc.to_html.index('id="publications"')
  end

  def test_home_uses_reference_typography_without_duplicate_anchor_offsets
    css = File.read(File.join(ROOT, "site/assets/css/global.css"))
    assert_includes css, '"Arial Rounded MT Bold"'
    assert_includes css, '"Permanent Marker"'
    assert_includes css, '"Comic Sans MS"'
    refute_match(/html\s*\{[^}]*scroll-padding-top/, css)
    assert_match(/\.home-section\s*\{[^}]*scroll-margin-top/, css)
    doc = page("index.html")
    assert doc.at_css('link[href*="fonts.googleapis.com/css2?family=Permanent+Marker"]')
    assert_includes doc.at_css("h1").text, "Welcome"
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
      assert_equal 4, text.scan(/\bPreprint\b/i).length, name
      assert_includes text, "92"
      assert_includes text, "4.70"
      refute_match(/under review|submitted|审稿中|已投稿/i, text)
      source = File.read(File.join(ROOT, "cv/#{name}.tex"))
      assert_equal 7, source.scan(/^\\researchentry\{/).length
      if name.end_with?("-zh")
        assert_includes source, "探索如何用有趣的方法简洁高效地解决人工智能研究中的各种问题，包括但不限于多模态大模型，视频/图片生成，具身智能"
      else
        assert_includes text, "MAIN INTERESTS"
        assert_includes text, "image/video generation"
      end
      ["AutoSearch", "OfferPilot", "FPGA Algorithm Optimization", "Research Skills", "精选软件与工程项目"].each do |term|
        refute_includes text, term
      end
      assert_includes text, "2/85"
      assert_includes text, "MAIN INTERESTS"
      fonts, status = Open3.capture2e("pdffonts", pdf)
      assert status.success?, fonts
      assert_includes fonts, "TimesNewRoman"
      refute_includes fonts, "CMSY", "Author symbols should use the CV text font, not a separate math font"
      [
        "From Scores to Checks: A Human-Annotated Rubric Benchmark for AI-Generated Image Faithfulness",
        "What Can Activation-Patching Evidence Establish?",
        "Follow Me If You Can: Auditing Understanding-to-Generation Transfer",
        "Allocation Entropy for Single-Pass Risk Triage in Neural Operators"
      ].each { |title| assert_includes source, title }
    end
  end
end
