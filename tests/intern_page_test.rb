require "minitest/autorun"
require "yaml"

class InternPageTest < Minitest::Test
  ROOT = File.expand_path("../site", __dir__)

  def test_intern_is_a_top_level_navigation_item
    navigation = YAML.safe_load(File.read(File.join(ROOT, "_data/navigation.yml")))
    intern = navigation.fetch("pages").find { |item| item["name"] == "Intern" }

    refute_nil intern
    assert_equal "/intern", intern["url"]
  end

  def test_logo_styles_use_the_latest_cache_busted_asset_version
    config = YAML.safe_load(File.read(File.join(ROOT, "_config.yml")))

    assert_equal "20260929-figures", config["asset_version"]
  end

  def test_intern_page_contains_three_internships_without_independent_research
    page = File.read(File.join(ROOT, "../intern.html"))
    styles = File.read(File.join(ROOT, "assets/css/global.css"))

    refute_includes page, "Independent Researcher"
    refute_includes page, "Apr. 2025 – Present"
    assert_includes page, "Tongji University"
    refute_includes page, "College of Electronic and Information Engineering"
    assert_includes page, "Oct. 2025 – Jun. 2026"
    refute_includes page, "School of Artificial Intelligence"
    assert_includes page, "Zhejiang University"
    assert_includes page, "Jun. 2026 – Sep. 2026"
    assert_includes page, "Hong Kong University of Science and Technology (Guangzhou)"
    refute_includes page, "The Hong Kong"
    assert_includes page, "Sep. 2026 – Present"
    assert_equal 1, page.scan("/assets/images/organizations/tongji-university.png").length
    assert_includes page, "/assets/images/organizations/zju-university.png"
    assert_includes page, "/assets/images/organizations/hkust-gz-icon.png"
    assert_includes page, "intern-logo-hkust"
    assert_equal 3, page.scan('class="intern-logo-wrap"').length
    refute_includes page, "intern-logo-personal"
    assert_includes page, "intern-logo-zju"
    assert_includes styles, ".intern-logo-zju"
    assert_includes styles, "transform: scale(1.6)"
    assert_includes styles, ".intern-logo-hkust"
    assert_includes styles, "height: 4.5rem"
    assert_includes page, "hkust-gz-icon.png"
    assert File.file?(File.join(ROOT, "assets/images/organizations/tongji-university.png"))
    assert File.file?(File.join(ROOT, "assets/images/organizations/zju-university.png"))
    assert File.file?(File.join(ROOT, "assets/images/organizations/hkust-gz-icon.png"))
  end
end
