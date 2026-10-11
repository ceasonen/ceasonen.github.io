require "minitest/autorun"
require "nokogiri"
require "yaml"
require "open3"
require "rexml/document"

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
    assert_equal "service", doc.css("main .home-section").last["id"]
    assert_operator doc.to_html.index('id="projects"'), :<, doc.to_html.index('id="publications"')
  end

  def test_navigation_order_matches_home_sections_with_cv_last
    doc = page("index.html")
    sections = doc.css("main .home-section").map { |section| section["id"] }
    links = doc.css(".section-nav a")
    anchors = links.reject { |link| link["href"].end_with?(".pdf") }
    assert_equal sections, anchors.map { |link| link["href"].delete_prefix("/#") }
    assert_equal "CV", links.last.text.strip
    assert_equal "/cv/cheng-chen-cv.pdf", links.last["href"]
  end

  def test_home_uses_reference_typography_without_duplicate_anchor_offsets
    css = File.read(File.join(ROOT, "site/assets/css/global.css"))
    assert_includes css, '"Nunito"'
    assert_includes css, '"Comic Sans MS"'
    assert_includes css, '@font-face'
    refute_includes css, '--detail-font'
    refute_match(/html\s*\{[^}]*scroll-padding-top/, css)
    assert_match(/\.home-section\s*\{[^}]*scroll-margin-top/, css)
    doc = page("index.html")
    assert doc.at_css('link[rel="preload"][as="font"][href="/assets/fonts/nunito-latin.woff2"]')
    assert_includes doc.at_css("h1").text, "Welcome"
  end

  def test_profile_has_lightweight_accessible_contact_icons
    doc = page("index.html")
    assert_equal 6, doc.css(".profile-links .site-icon").length
    doc.css(".profile-links .site-icon").each do |icon|
      assert_equal "true", icon["aria-hidden"]
    end
    assert_equal "Tongji University", doc.at_css(".profile-affiliation").text
    assert doc.at_css('.profile-links a[href="mailto:2351445@tongji.edu.cn"]')
    assert doc.at_css('.profile-links a[href="mailto:chenceason10@gmail.com"]')
    assert doc.at_css(".welcome-wave")
    assert_equal 2, doc.css(".education-entry .education-icon").length
  end

  def test_undergraduate_education_displays_major_rank
    entry = page("index.html").css(".education-entry").find { |item| item.at_css("h3").text == "Tongji University" }
    refute_nil entry
    assert_includes entry.text, "Major rank: 2/85"
  end

  def test_intro_separates_current_affiliation_from_future_phd
    doc = page("index.html")
    note = doc.at_css(".intro-phd-note")
    refute_nil note
    assert_includes note.text, "September 2027"
    assert_includes note.text, "Prof. Kaiqi Huang"
    assert_includes doc.at_css(".introduction > p").text, "Tongji University"
  end

  def test_intro_describes_current_interests_and_undergraduate_major
    paragraphs = page("index.html").css(".introduction > p")
    opening = paragraphs.first.text.strip
    assert opening.start_with?("I'm an undergraduate student majoring in Communication Engineering at Tongji University")
    interests = paragraphs.last.text.strip
    assert_equal "I explore simple, elegant ways to make AI models more capable. My interests span multimodal large language models, image/video generation, and embodied AI.", interests
    assert_empty page("index.html").css(".research-interests")
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
      assert_includes text, "92.02/100"
      assert_includes text, "4.70"
      refute_match(/under review|submitted|审稿中|已投稿/i, text)
      source = File.read(File.join(ROOT, "cv/#{name}.tex"))
      assert_equal 7, source.scan(/^\\researchentry\{/).length
      if name.end_with?("-zh")
        assert_includes source, "探索以简洁、优雅的方法提升模型能力"
      else
        assert_includes text, "Main interests"
        assert_includes text, "image/video generation"
      end
      ["AutoSearch", "OfferPilot", "FPGA Algorithm Optimization", "Research Skills", "精选软件与工程项目"].each do |term|
        refute_includes text, term
      end
      assert_includes text, "2/85"
      assert_includes text, "Main interests"
      fonts, status = Open3.capture2e("pdffonts", pdf)
      assert status.success?, fonts
      assert_includes fonts, "CMUSerif"
      refute_includes fonts, "TimesNewRoman"
      refute_includes fonts, "CMSY", "Author symbols should use the CV text font, not a separate math font"
      assert_includes text, "2351445@tongji.edu.cn"
      assert_includes text, "chenceason10@gmail.com"
      [
        "From Scores to Checks: A Human-Annotated Rubric Benchmark for AI-Generated Image Faithfulness",
        "What Can Activation-Patching Evidence Establish?",
        "Follow Me If You Can: Auditing Understanding-to-Generation Transfer",
        "Allocation Entropy for Single-Pass Risk Triage in Neural Operators"
      ].each { |title| assert_includes source, title }
    end
  end

  def test_main_cv_builds_have_no_overflow_or_missing_glyphs
    %w[cheng-chen-cv cheng-chen-cv-zh].each do |name|
      log = File.join(ROOT, ".build/cv/#{name}/build.log")
      next unless File.file?(log)
      refute_match(/Overfull \\hbox|Missing character|LaTeX Font Warning/, File.read(log), name)
    end
  end

  def test_photo_cv_text_remains_inside_the_page
    text, status = Open3.capture2e("pdftotext", "-bbox", File.join(ROOT, "cv/cheng-chen-resume-photo-zh.pdf"), "-")
    assert status.success?
    doc = REXML::Document.new(text)
    REXML::XPath.match(doc, '//*[local-name()="page"]').each do |page|
      words = REXML::XPath.match(page, './/*[local-name()="word"]')
      assert_operator words.map { |word| word.attributes["yMax"].to_f }.max, :<=, page.attributes["height"].to_f - 12
    end
  end
end
