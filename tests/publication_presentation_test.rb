require "minitest/autorun"
require "nokogiri"
require "yaml"
require "date"

class PublicationPresentationTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  PREPRINT_TITLES = [
    "From Scores to Checks: A Human-Annotated Rubric Benchmark for AI-Generated Image Faithfulness",
    "What Can Activation-Patching Evidence Establish?",
    "Follow Me If You Can: Auditing Understanding-to-Generation Transfer",
    "Allocation Entropy for Single-Pass Risk Triage in Neural Operators"
  ].freeze
  VERIFIED_PDFS = {
    "If You Hear It, Help Find It: Orthogonal Knowledge Distillation for Open-Vocabulary Audio-Visual Event Localization" => "https://arxiv.org/pdf/2609.23376",
    "OrthKD: Extracting Generalized Clinical Knowledge from Heterogeneous Teachers for Lightweight Deployment" => "https://arxiv.org/pdf/2607.25545",
    "Enabling Visual Reasoning in Text-Only LLMs via Symbolic Scene Descriptions" => "https://ceasonen.github.io/assets/papers/deepyolo-ijcnn-2026.pdf"
  }.freeze

  def test_direct_pdf_links_are_shared_by_home_and_main_cvs
    doc = Nokogiri::HTML(File.read(File.join(ROOT, "index.html")))
    VERIFIED_PDFS.each do |title, url|
      card = doc.css(".publication-card").find { |item| item.at_css("h3").text == title }
      refute_nil card
      link = card.at_css(".publication-links a[href='#{url}']")
      refute_nil link, "Missing direct PDF link for #{title}"
      assert_equal "[PDF]", link.text.strip
      %w[cheng-chen-cv cheng-chen-cv-zh].each do |name|
        assert_includes File.read(File.join(ROOT, "cv/#{name}.tex")), "\\href{#{url}}{[PDF]}"
      end
    end
  end

  def test_ijcnn_public_pdf_is_available_without_a_researchgate_login
    %w[site .build/site].each do |folder|
      path = File.join(ROOT, folder, "assets/papers/deepyolo-ijcnn-2026.pdf")
      assert File.file?(path), "Missing public IJCNN PDF in #{folder}"
      assert_equal "%PDF-", File.binread(path, 5)
      assert_operator File.size(path), :<, 2_000_000
    end
  end

  def publications
    Dir[File.join(ROOT, "site/_publications/**/*.md")].map do |file|
      YAML.safe_load(File.read(file).split("---", 3)[1], permitted_classes: [Date, Time])
    end.sort_by { |entry| entry.fetch("rank") }
  end

  def test_preprints_have_full_titles_and_covers_but_no_authors_or_manuscript_links
    anonymous = publications.select { |entry| entry["anonymous"] }
    assert_equal PREPRINT_TITLES, anonymous.map { |entry| entry.fetch("title") }
    assert_equal 3, anonymous.count { |entry| entry["pub"] == "ICLR" }
    assert_equal 1, anonymous.count { |entry| entry["pub"] == "AAAI" }
    anonymous.each do |entry|
      assert_includes entry.fetch("pub_last"), "Preprint"
      refute_match(/Under Review|Submitted/i, entry.fetch("pub_last"))
      refute_nil entry["cover"], "Missing figure cover for #{entry['title']}"
      assert File.file?(File.join(ROOT, "site", entry.fetch("cover")))
      assert_nil entry["authors"]
      assert_nil entry["links"]
    end
  end

  def test_all_publication_surfaces_use_the_same_order_and_images
      doc = Nokogiri::HTML(File.read(File.join(ROOT, "index.html")))
      entries = publications
      cards = doc.css(".publication-card")
      assert_equal entries.map { |entry| entry.fetch("title") }, cards.map { |card| card.at_css("h3").text }
      assert_equal 3, cards.index { |card| card["data-submission"] }
      cards.zip(entries).each do |card, entry|
          image = card.at_css("img.publication-cover")
          refute_nil image, "Missing figure for #{entry['title']}"
          assert_equal entry.fetch("cover"), image["src"]
          assert_nil card.at_css(".fa-file-alt"), "File icon should not replace a paper figure"
          assert_nil card.at_css(".publication-authors") if entry["anonymous"]
          assert_equal "Preprint 2026", card.at_css(".publication-venue").text.strip if entry["anonymous"]
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

  def test_publication_filters_share_a_single_set_of_visible_paper_cards
    doc = Nokogiri::HTML(File.read(File.join(ROOT, "index.html")))
    buttons = doc.css(".publication-filter")
    assert_equal %w[all accepted preprint], buttons.map { |button| button["data-filter"] }
    assert_equal %w[true false false], buttons.map { |button| button["aria-pressed"] }
    assert_equal 7, doc.css(".publication-card").length
    assert_equal 3, doc.css('.publication-card[data-status="accepted"]').length
    assert_equal 4, doc.css('.publication-card[data-status="preprint"]').length
    assert_empty doc.css(".publication-card[hidden]")
    assert_equal "7 papers", doc.at_css(".publication-count").text.strip
  end

  def test_accepted_papers_use_concise_venue_labels_after_the_summary
    doc = Nokogiri::HTML(File.read(File.join(ROOT, "index.html")))
    cards = doc.css('.publication-card[data-status="accepted"]')
    assert_equal ["ACM MM 2026", "IJCAI 2026", "IJCNN 2026"], cards.map { |card| card.at_css(".publication-venue strong").text }
    cards.each do |card|
      assert_operator card.to_html.index('class="publication-summary"'), :<, card.to_html.index('class="publication-venue"')
    end
  end
end
