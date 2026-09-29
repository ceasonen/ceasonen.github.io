require "minitest/autorun"
require "nokogiri"
require "yaml"
require "date"

class PublicationPresentationTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def publications
    Dir[File.join(ROOT, "site/_publications/**/*.md")].map do |file|
      YAML.safe_load(File.read(file).split("---", 3)[1], permitted_classes: [Date, Time])
    end.sort_by { |entry| entry.fetch("rank") }
  end

  def test_review_entries_have_real_covers_without_identifying_metadata
    publications.select { |entry| entry["anonymous"] }.each do |entry|
      refute_nil entry["cover"], "Missing figure cover for #{entry['title']}"
      assert File.file?(File.join(ROOT, "site", entry.fetch("cover")))
      assert_nil entry["authors"]
      assert_nil entry["links"]
    end
  end

  def test_all_publication_surfaces_use_the_same_order_and_images
    %w[index.html publications.html awards.html].each do |file|
      doc = Nokogiri::HTML(File.read(File.join(ROOT, file)))
      entries = file == "publications.html" ? publications : publications.select { |entry| entry["selected"] }
      %w[.publication-item.d-none .publication-item.d-md-none].each do |selector|
        cards = doc.css(selector)
        assert_equal entries.map { |entry| entry.fetch("title") }, cards.map { |card| card.at_css("h5").text }, "#{file}: #{selector}"
        cards.zip(entries).each do |card, entry|
          image = card.at_css("img.publication-cover")
          refute_nil image, "#{file}: missing figure for #{entry['title']}"
          assert_equal entry.fetch("cover"), image["src"]
          assert_nil card.at_css(".fa-file-alt"), "File icon should not replace a paper figure"
        end
      end
    end
  end

  def test_no_dedicated_review_disclaimers_remain
    %w[index.html publications.html awards.html].each do |file|
      text = Nokogiri::HTML(File.read(File.join(ROOT, file))).text
      refute_includes text, "Details withheld during review"
      refute_includes text, "Research topic ·"
      refute_includes text, "Entries under review use broad topic descriptions"
    end
  end
end
