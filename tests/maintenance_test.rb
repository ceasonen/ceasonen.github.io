require "minitest/autorun"
require "yaml"
require "json"
require "open3"
require "rbconfig"

class MaintenanceTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def data(name)
    path = File.join(ROOT, "site/_data/#{name}.yml")
    assert File.file?(path), "Missing editable data file: site/_data/#{name}.yml"
    YAML.safe_load(File.read(path))
  end

  def test_research_areas_have_one_editing_location
    areas = data("research")
    assert_equal 4, areas.length
    template = File.read(File.join(ROOT, "site/index.html"))
    assert_includes template, "site.data.research"
    page = File.read(File.join(ROOT, "index.html"))
    areas.each { |area| assert_includes page, area }
  end

  def test_internships_are_data_driven
    entries = data("internships")
    assert_equal 3, entries.length
    assert_includes File.read(File.join(ROOT, "site/_includes/sections/experience.html")), "site.data.internships"
    page = File.read(File.join(ROOT, "index.html"))
    entries.each do |entry|
      %w[role organization date logo].each { |field| assert_includes page, entry.fetch(field) }
      assert File.file?(File.join(ROOT, "site", entry.fetch("logo")))
    end
  end

  def test_highlights_are_data_driven
    highlights = data("highlights")
    assert_equal 7, highlights.fetch("awards").length
    assert_includes File.read(File.join(ROOT, "site/index.html")), "site.data.highlights"
  end

  def test_workspace_points_to_existing_editing_folders
    path = File.join(ROOT, "website.code-workspace")
    assert File.file?(path), "Missing maintenance workspace"
    workspace = JSON.parse(File.read(path))
    workspace.fetch("folders").each do |folder|
      assert Dir.exist?(File.join(ROOT, folder.fetch("path"))), folder.fetch("path")
      refute_equal ".", folder.fetch("path"), "Workspace should not mix generated root files into editing folders"
    end
  end

  def test_command_entry_is_independent_of_current_directory
    path = File.join(ROOT, "tools/website.rb")
    assert File.file?(path), "Missing unified maintenance command"
    output, status = Open3.capture2e(RbConfig.ruby, path, "help", chdir: File.join(ROOT, "cv"))
    assert status.success?, output
    %w[build check preview cv].each { |command| assert_includes output, command }
    output, status = Open3.capture2e(RbConfig.ruby, path, "unknown")
    refute status.success?
    assert_includes output, "Unknown command"
  end

  def test_preview_contains_public_cv_but_no_working_materials
    preview = File.join(ROOT, ".build/site")
    assert File.file?(File.join(preview, "cv/cheng-chen-cv.pdf")), "Build must retain the preview CV after every rebuild"
    %w[.local .git papers Gemfile README.md cv/cheng-chen-cv.tex].each do |private_path|
      refute File.exist?(File.join(preview, private_path)), "Unexpected working material in preview: #{private_path}"
    end
  end

  def test_published_pages_explain_where_to_edit
    %w[index.html publications.html projects.html news.html intern.html awards.html 404.html].each do |page|
      assert File.read(File.join(ROOT, page)).start_with?("<!-- GENERATED FILE: edit site/"), "Missing source reminder in #{page}"
    end
  end
end
