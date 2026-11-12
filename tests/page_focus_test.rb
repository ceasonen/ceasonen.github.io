require "minitest/autorun"
require "nokogiri"
require "yaml"
require "open3"
require "rexml/document"

class PageFocusTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  CV_EN_URL = "/cv/cheng-chen-cv.pdf?v=20261112-scholarship-year"
  CV_ZH_URL = "/cv/cheng-chen-cv-zh.pdf?v=20261112-scholarship-year"

  def page(name)
    path = File.join(ROOT, name)
    assert File.file?(path), "Missing published page: #{name}"
    Nokogiri::HTML(File.read(path))
  end

  def test_projects_are_compact_linked_text_with_verified_repositories
    doc = page("index.html")
    entries = doc.css("#projects .project-list > li")
    assert_equal 5, entries.length
    assert_empty doc.css("#projects .project-card, #projects details, #projects .project-stack")
    %w[Image2Other deep-research offer-pilot hlstrack2025-44686 research-skills].each do |repo|
      assert doc.at_css("#projects a[href='https://github.com/ceasonen/#{repo}']"), repo
    end
    entries.each do |entry|
      refute_empty entry.at_css(".project-name").text.strip
      refute_empty entry.at_css(".project-summary").text.strip
    end
    studio = doc.at_css('#projects .project-name[href="https://ceasonen.github.io/Image2Other/"]')
    refute_nil studio
    assert_equal "Image2Other", studio.text.strip
  end

  def test_project_subsites_are_linked_and_explain_runtime_requirements
    home = page("index.html")
    {
      "offer-pilot" => ["OfferPilot", "AI interview", "server"],
      "deep-research" => ["AutoSearch AI", "research", "FastAPI"]
    }.each do |slug, terms|
      link = home.at_css("#projects .project-name[href='https://ceasonen.github.io/#{slug}/']")
      refute_nil link, "Missing project entry for #{slug}"
      project = page("#{slug}/index.html")
      assert_equal "#{slug}", project.at_css("body")["data-project"]
      terms.each { |term| assert_includes project.text.downcase, term.downcase }
      assert project.at_css("a[href='https://github.com/ceasonen/#{slug}']")
      assert project.at_css("a[href='https://ceasonen.github.io/']")
    end
  end

  def test_project_subsites_survive_the_next_site_build
    source_projects = YAML.load_file(File.join(ROOT, "site/_data/projects.yml"))
    %w[offer-pilot deep-research].each do |slug|
      entry = source_projects.find { |project| project["repository"] == "https://github.com/ceasonen/#{slug}" }
      refute_nil entry
      assert_equal "https://ceasonen.github.io/#{slug}/", entry["website"]
      assert File.file?(File.join(ROOT, "site/#{slug}/index.html"))
    end
    build_script = File.read(File.join(ROOT, "tools/build_site.rb"))
    assert_includes build_script, "offer-pilot/index.html"
    assert_includes build_script, "deep-research/index.html"
    link_checker = File.read(File.join(ROOT, "tools/check_site.rb"))
    assert_includes link_checker, "offer-pilot/index.html"
    assert_includes link_checker, "deep-research/index.html"
  end

  def test_legacy_pages_redirect_to_home_sections
    {"publications" => "publications", "projects" => "projects", "intern" => "experience", "news" => "news", "awards" => "awards"}.each do |path, section|
      doc = page("#{path}.html")
      assert_equal "0; url=/##{section}", doc.at_css('meta[http-equiv="refresh"]')["content"]
      assert_empty doc.css(".publication-card, .project-list, .experience-card")
    end
  end

  def test_home_navigation_targets_sections_that_exist_once
    doc = page("index.html")
    doc.css(".section-nav a").each do |link|
      next if link["href"].include?(".pdf")
      assert link["href"].start_with?("/#"), link["href"]
      assert_equal 1, doc.css(link["href"].delete_prefix("/")).length
    end
    assert_equal 3, doc.css("#experience .experience-card").length
    assert_equal 5, doc.css("#projects .project-list > li").length
    assert_equal 3, doc.css("#publications .publication-card").length
    assert_equal "service", doc.css("main .home-section").last["id"]
    assert_operator doc.to_html.index('id="projects"'), :<, doc.to_html.index('id="publications"')
  end

  def test_navigation_order_matches_home_sections_with_both_cvs_last
    doc = page("index.html")
    sections = doc.css("main .home-section").map { |section| section["id"] }
    links = doc.css(".section-nav a")
    anchors = links.reject { |link| link["href"].include?(".pdf") }
    assert_equal sections, anchors.map { |link| link["href"].delete_prefix("/#") }
    cv_links = links.to_a.last(2)
    assert_equal ["CV (EN)", "CV (ZH)"], cv_links.map { |link| link.text.strip }
    assert_equal [CV_EN_URL, CV_ZH_URL], cv_links.map { |link| link["href"] }
    cv_links.each { |link| assert_equal "_blank", link["target"] }
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
    doc.css(".profile-links svg.site-icon").each do |icon|
      assert_equal "true", icon["aria-hidden"]
    end
    assert_equal "Tongji University", doc.at_css(".profile-affiliation").text
    assert_empty doc.css('.profile-links a[href^="mailto:"]')
    assert_empty doc.css('.profile-links a[href*=".pdf"]')
    assert_equal ["Google Scholar", "GitHub", "LinkedIn", "Twitter", "RedNote"], doc.css(".profile-links a").map { |link| link.text.strip }
    css = File.read(File.join(ROOT, "site/assets/css/global.css"))
    assert_match(/\.profile-links\s*\{[^}]*font-size:\s*14px\b/m, css)
    assert doc.at_css(".welcome-wave")
    assert_equal 1, doc.css(".education-entry .education-icon").length
  end

  def test_contact_invitation_uses_gmail_in_the_main_text
    doc = page("index.html")
    contact = doc.at_css("#about .intro-contact")
    refute_nil contact
    assert_includes contact.text, "Feel free to email me"
    link = contact.at_css('a[href="mailto:chenceason10@gmail.com"]')
    refute_nil link
    assert_equal "chenceason10@gmail.com", link.text.strip
    assert_empty doc.css(".profile-links a[href^='mailto:']")
    assert_empty page("2026/03/17/acknowledgement.html").css(".sidebar-links a[href^='mailto:']")
  end

  def test_cv_links_stay_in_top_navigation_only
    doc = page("index.html")
    assert_empty doc.css("#about .intro-cv")
    links = doc.css(".section-nav a[href*='.pdf']")
    assert_equal [CV_EN_URL, CV_ZH_URL], links.map { |link| link["href"] }
    assert_empty doc.css('.profile-links a[href*=".pdf"]')
  end

  def test_x_profile_link_uses_the_supplied_account
    url = "https://x.com/CeasonC87891"
    profile = YAML.safe_load(File.read(File.join(ROOT, "site/_data/profile.yml")))
    assert_equal url, profile["x_url"]
    link = page("index.html").at_css(".profile-links a[href='#{url}']")
    refute_nil link
    assert_equal "Twitter", link.text.strip
    assert_equal "_blank", link["target"]
    assert_includes link["rel"], "noopener"
    assert link.at_css("svg.site-icon.icon-x[aria-hidden='true']")
    assert_includes File.read(File.join(ROOT, "site/_includes/widgets/homepage_sidebar.html")), "site.data.profile.x_url"
  end

  def test_linkedin_profile_link_uses_the_supplied_account
    url = "https://www.linkedin.com/in/cheng-chen-012a83378/"
    profile = YAML.safe_load(File.read(File.join(ROOT, "site/_data/profile.yml")))
    assert_equal url, profile["linkedin_url"]
    link = page("index.html").at_css(".profile-links a[href='#{url}']")
    refute_nil link
    assert_equal "LinkedIn", link.text.strip
    assert_equal "_blank", link["target"]
    assert_includes link["rel"], "noopener"
    assert link.at_css("svg.site-icon[aria-hidden='true']")
    assert page("2026/03/17/acknowledgement.html").at_css(".sidebar-links a[href='#{url}']")
  end

  def test_xiaohongshu_profile_link_uses_the_supplied_account
    url = "https://www.xiaohongshu.com/user/profile/6587c475000000003d037c4f"
    profile = YAML.safe_load(File.read(File.join(ROOT, "site/_data/profile.yml")))
    assert_equal url, profile["xiaohongshu_url"]
    link = page("index.html").at_css(".profile-links a[href='#{url}']")
    refute_nil link
    assert_equal "RedNote", link.text.strip
    assert_equal "_blank", link["target"]
    assert_includes link["rel"], "noopener"
    icon = link.at_css('img.site-icon.icon-xiaohongshu[src="https://www.xiaohongshu.com/favicon.ico"]')
    refute_nil icon
    assert_equal "", icon["alt"]
    assert page("2026/03/17/acknowledgement.html").at_css(".sidebar-links a[href='#{url}']")
  end

  def test_social_icons_use_brand_marks
    doc = page("index.html")
    {
      "Google Scholar" => "M5.242 13.769",
      "GitHub" => "M12 .297",
      "LinkedIn" => "M20.447 20.452",
      "Twitter" => "M14.234 10.162"
    }.each do |label, path_start|
      link = doc.css(".profile-links a").find { |item| item.text.strip == label }
      refute_nil link, label
      path = link.at_css("svg path")
      refute_nil path, label
      assert path["d"].start_with?(path_start), label
    end
  end

  def test_all_english_cv_entry_points_request_the_current_pdf
    home = File.read(File.join(ROOT, "site/index.html"))
    navigation = File.read(File.join(ROOT, "site/_data/navigation.yml"))
    sidebar = File.read(File.join(ROOT, "site/_includes/widgets/homepage_sidebar.html"))
    redirect = File.read(File.join(ROOT, "cv/index.html"))
    refute_includes home, CV_EN_URL
    assert_includes navigation, CV_EN_URL
    refute_includes sidebar, CV_EN_URL
    assert_equal 4, redirect.scan(CV_EN_URL).length
  end

  def test_chinese_cv_entry_points_request_the_current_pdf
    home = File.read(File.join(ROOT, "site/index.html"))
    navigation = File.read(File.join(ROOT, "site/_data/navigation.yml"))
    refute_includes home, CV_ZH_URL
    assert_includes navigation, CV_ZH_URL
  end

  def test_service_is_plain_typography_without_nested_cards
    doc = page("index.html")
    service = doc.at_css("#service")
    assert_equal "Reviewer", service.at_css(".service-heading")&.text&.strip
    assert_equal ["ICLR(2027)", "AAAI(2027)", "ICME(2026)", "IJCNN(2026,2027)", "PRCV(2026)"],
                 service.css(".service-list li").map { |item| item.text.strip }
    assert_empty service.css(".service-panel, .service-venues")
    css = File.read(File.join(ROOT, "site/assets/css/global.css"))
    refute_match(/\.service-list\s*\{[^}]*\b(?:border|background|box-shadow)\s*:/, css)
  end

  def test_undergraduate_education_displays_major_rank
    entry = page("index.html").css(".education-entry").find { |item| item.at_css("h3").text == "Tongji University" }
    refute_nil entry
    assert_includes entry.text, "Major rank: 2/85"
  end

  def test_profile_lists_only_current_undergraduate_education
    doc = page("index.html")
    profile = YAML.safe_load(File.read(File.join(ROOT, "site/_data/profile.yml")))
    assert_equal ["Tongji University"], profile.fetch("education").map { |item| item.fetch("name") }
    assert_equal ["Tongji University"], profile.fetch("positions").map { |item| item.fetch("name") }
    assert_equal ["Tongji University"], doc.css(".education-entry h3").map { |heading| heading.text.strip }
    assert_empty doc.css(".intro-phd-note")
    refute_match(/incoming|ph\.?d|kaiqi|chinese academy of sciences/i, doc.text)
    assert_includes doc.at_css(".introduction > p").text, "Tongji University"
  end

  def test_intro_describes_current_interests_and_undergraduate_major
    paragraphs = page("index.html").css(".introduction > p")
    opening = paragraphs.first.text.strip
    assert opening.start_with?("I'm an undergraduate student majoring in Communication Engineering at Tongji University")
    interests = paragraphs[1].text.strip
    assert_equal "I explore simple, efficient ways to make AI more capable, from learning algorithms to the systems that train and deploy models. My interests span multimodal foundation models, image/video generation, AI infrastructure, and reinforcement learning for embodied agents.", interests
    assert_empty page("index.html").css(".research-interests")
  end

  def test_sidebar_bio_matches_current_research_interests
    sidebar_bio = YAML.safe_load(File.read(File.join(ROOT, "site/_data/profile.yml"))).fetch("sidebar_bio")
    assert_includes sidebar_bio, "multimodal foundation models, AI infrastructure, and reinforcement learning"
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
      refute_match(/\bPreprints?\b/i, text, name)
      assert_includes text, "92.02/100"
      assert_includes text, "4.70"
      refute_match(/under review|审稿中/i, text)
      source = File.read(File.join(ROOT, "cv/#{name}.tex"))
      assert_equal 3, source.scan(/^\\researchentry\{/).length
      if name.end_with?("-zh")
        assert_includes source, "我探索以简洁高效的方法提升 AI 能力"
      else
        assert_includes text, "Main interests"
        assert_includes text, "image/video generation"
        assert_includes text, "AI infrastructure"
        assert_includes text, "reinforcement learning"
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
      ].each { |title| refute_includes source, title }
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
