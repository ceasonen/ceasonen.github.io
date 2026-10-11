require "minitest/autorun"
require "nokogiri"
require "yaml"

class DesignRefinementTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def home
    Nokogiri::HTML(File.read(File.join(ROOT, "index.html")))
  end

  def test_education_uses_ucas_and_tongji_emblems_without_placeholder_icons
    entries = home.css(".education-entry")
    assert_equal 2, entries.length
    entries.zip(%w[ucas-university.png tongji-university.png]).each do |entry, filename|
      images = entry.css(".education-icon img")
      assert_equal 1, images.length, filename
      assert_equal "/assets/images/organizations/#{filename}", images.first["src"]
      refute_empty images.first["alt"]
      assert_equal images.first["width"], images.first["height"]
      assert File.file?(File.join(ROOT, "site", images.first["src"]))
      assert_empty entry.css(".education-icon .site-icon")
    end
  end

  def test_iclr_news_has_one_consolidated_update
    items = home.css(".news-list li").select { |item| item.text.include?("ICLR 2027") }
    assert_equal 1, items.length
    assert_includes items.first.text, "Three papers"
    assert_equal "2026.10", items.first.at_css("time").text
  end

  def test_browser_icon_is_a_vector_rubiks_cube_with_a_fresh_cache_key
    icon = Nokogiri::XML(File.read(File.join(ROOT, "favicon.svg")))
    icon.remove_namespaces!
    assert_equal "0 0 32 32", icon.at_css("svg")["viewBox"]
    assert_equal 3, icon.css("polygon").length
    assert_equal ["#b6e21a", "#1679dc", "#ef4444"], icon.css("polygon").map { |face| face["fill"] }
    assert_equal 3, icon.css("path").length
    assert_empty icon.css("text, image")
    %w[index.html 404.html].each do |page|
      doc = Nokogiri::HTML(File.read(File.join(ROOT, page)))
      assert_equal "/favicon.svg?v=rubik-1", doc.at_css('link[rel="icon"]')["href"], page
    end
  end

  def test_displayed_text_has_no_parenthetical_acronym_expansions
    refute_match(/\([A-Z][A-Z0-9-]{1,}\)/, home.at_css("main").text)
    refute_includes home.text, "(CRAIC)"
  end

  def test_awards_separate_prize_organization_year_and_role
    entries = YAML.safe_load(File.read(File.join(ROOT, "site/_data/highlights.yml"))).fetch("awards")
    cards = home.css(".award-card")
    assert_equal 7, cards.length
    cards.zip(entries).each do |card, entry|
      assert_equal entry.fetch("name"), card.at_css("h3").text.strip
      assert_equal entry.fetch("prize"), card.at_css(".award-prize").text.strip
      assert_equal entry.fetch("date"), card.at_css("time").text.strip
      assert_includes card.text, entry.fetch("role") if entry["role"]
      assert_includes card.text, entry.fetch("detail") if entry["detail"]
    end
    assert_equal 1, home.css(".award-card--featured").length
    assert_equal 7, home.css(".award-card .site-icon").length
  end

  def test_competition_names_use_verified_event_or_institutional_english_names
    expected = [
      "China Robot and Artificial Intelligence Competition",
      "Global Campus Artificial Intelligence Algorithm Elite Competition",
      "National Undergraduate Embedded Chip and System Design Competition",
      "Contemporary Undergraduate Mathematical Contest in Modeling",
      "National College Student Statistical Modeling Competition",
      "The Chinese Mathematics Competitions"
    ]
    entries = YAML.safe_load(File.read(File.join(ROOT, "site/_data/highlights.yml"))).fetch("awards")
    assert_equal expected, entries.first(6).map { |entry| entry.fetch("name") }
    news = Dir[File.join(ROOT, "site/_news/*.md")].map { |path| File.read(path) }.join("\n")
    expected.each { |name| assert_includes news, name }
  end

  def test_typography_is_self_hosted_and_has_no_secondary_font_stack
    css = File.read(File.join(ROOT, "site/assets/css/global.css"))
    refute_match(/Segoe UI|Verdana|--detail-font|Permanent Marker/, css)
    assert_includes css, 'font-family: "Nunito"'
    assert_includes css, 'font-weight: 400 900'
    assert File.size?(File.join(ROOT, "site/assets/fonts/nunito-latin.woff2"))
    assert_empty home.css('link[href*="fonts.googleapis.com"]')
  end

  def test_modeling_awards_and_news_use_provincial_labels
    refute_match(/Shanghai (First|Second|Third) Prize/, home.text)
    modeling_events = [
      "Contemporary Undergraduate Mathematical Contest in Modeling",
      "National College Student Statistical Modeling Competition"
    ]
    cards = home.css(".award-card").select { |card| modeling_events.include?(card.at_css("h3").text.strip) }
    assert_equal 2, cards.length
    cards.each { |card| assert_equal "Provincial Third Prize", card.at_css(".award-prize").text.strip }
    %w[2025-11-20 2025-06-15].each do |date|
      news = home.at_css(".news-list time[datetime='#{date}']").parent.text
      assert_includes news, "Provincial Third Prize"
    end
  end
end
