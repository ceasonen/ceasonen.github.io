require "minitest/autorun"
require "yaml"

class InternPageTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_intern_is_a_top_level_navigation_item
    navigation = YAML.safe_load(File.read(File.join(ROOT, "_data/navigation.yml")))
    intern = navigation.fetch("pages").find { |item| item["name"] == "Intern" }

    refute_nil intern
    assert_equal "/intern", intern["url"]
  end

  def test_logo_styles_use_the_latest_cache_busted_asset_version
    config = YAML.safe_load(File.read(File.join(ROOT, "_config.yml")))

    assert_equal "20260902-2", config["asset_version"]
  end

  def test_intern_page_contains_all_three_experiences
    page = File.read(File.join(ROOT, "intern.html"))
    styles = File.read(File.join(ROOT, "assets/css/global.css"))

    assert_includes page, "Independent Researcher"
    assert_includes page, "Apr. 2025 – Present"
    assert_includes page, "College of Electronic and Information Engineering"
    assert_includes page, "Oct. 2025 – Jun. 2026"
    assert_includes page, "School of Artificial Intelligence"
    assert_includes page, "Zhejiang University"
    assert_includes page, "Jul. 2026 – Present"
    assert_equal 2, page.scan("/assets/images/organizations/tongji-university.png").length
    assert_includes page, "/assets/images/organizations/zju-university.png"
    assert_equal 3, page.scan('class="intern-logo-wrap"').length
    refute_includes page, "intern-logo-personal"
    assert_includes page, "intern-logo-zju"
    assert_includes styles, ".intern-logo-zju"
    assert_includes styles, "transform: scale(1.6)"
    assert File.file?(File.join(ROOT, "assets/images/organizations/tongji-university.png"))
    assert File.file?(File.join(ROOT, "assets/images/organizations/zju-university.png"))
  end
end
