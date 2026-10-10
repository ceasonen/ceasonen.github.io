require "minitest/autorun"
require "nokogiri"
require "yaml"

class DesignRefinementTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def home
    Nokogiri::HTML(File.read(File.join(ROOT, "index.html")))
  end

  def test_iclr_news_has_one_consolidated_update
    items = home.css(".news-list li").select { |item| item.text.include?("ICLR 2027") }
    assert_equal 1, items.length
    assert_includes items.first.text, "Three papers"
    assert_equal "2026.10", items.first.at_css("time").text
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

  def test_typography_is_self_hosted_and_has_no_secondary_font_stack
    css = File.read(File.join(ROOT, "site/assets/css/global.css"))
    refute_match(/Segoe UI|Verdana|--detail-font|Permanent Marker/, css)
    assert_includes css, 'font-family: "Nunito"'
    assert_includes css, 'font-weight: 400 900'
    assert File.size?(File.join(ROOT, "site/assets/fonts/nunito-latin.woff2"))
    assert_empty home.css('link[href*="fonts.googleapis.com"]')
  end
end
