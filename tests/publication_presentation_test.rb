require "minitest/autorun"
require "nokogiri"
require "yaml"
require "date"

class PublicationPresentationTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  VERIFIED_PDFS = {
    "If You Hear It, Help Find It: Orthogonal Knowledge Distillation for Open-Vocabulary Audio-Visual Event Localization" => "https://arxiv.org/pdf/2609.23376",
    "OrthKD: Extracting Generalized Clinical Knowledge from Heterogeneous Teachers for Lightweight Deployment" => "https://ijcai.org/proceedings/2026/0774.pdf",
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

  def test_publications_only_include_accepted_or_published_papers
    assert_equal 3, publications.length
    assert_empty publications.select { |entry| entry["preprint"] }
    publications.each { |entry| assert_nil entry["submission_note"] }
  end

  def test_accepted_paper_roles_match_confirmed_authorship
    accepted = publications.reject { |entry| entry["preprint"] }
    assert_equal ["Cheng Chen*", "Yi Xu*‡", "Wenzhuo Lei†"], accepted[0].fetch("authors")
    assert_equal ["Yi Xu*†", "Cheng Chen*‡", "Mufan Cao"], accepted[1].fetch("authors")
    assert_equal ["Wenzhuo Lei", "Mufan Cao", "Chaorong Ye", "Yi Xu", "Cheng Chen†‡"], accepted[2].fetch("authors")
    doc = Nokogiri::HTML(File.read(File.join(ROOT, "index.html")))
    assert_equal "* Equal contribution · † Corresponding author · ‡ Project lead", doc.at_css(".publication-legend").text.strip
    cards = doc.css(".publication-card")
    cards.first(3).each do |card|
      assert card.at_css(".publication-authors"), card.at_css("h3").text
    end
    assert_includes cards[0].at_css(".publication-authors").text, "Yi Xu*‡"
    assert_includes cards[0].at_css(".publication-authors").text, "Wenzhuo Lei†"
    assert_includes cards[1].at_css(".publication-authors").text, "Cheng Chen*‡"
    assert_includes cards[2].at_css(".publication-authors").text, "Cheng Chen†‡"
    assert_empty doc.css(".publication-card[data-submission]")
  end

  def test_publication_role_marks_are_legible_and_links_are_verified
    doc = Nokogiri::HTML(File.read(File.join(ROOT, "index.html")))
    assert_equal 3, doc.css(".publication-legend strong").length
    assert_equal %w[* † ‡], doc.css(".publication-legend strong").map(&:text)
    assert_includes doc.css(".publication-card").first.css(".publication-authors sup").map(&:text), "‡"

    cards = doc.css(".publication-card")
    mm_links = cards[0].css(".publication-links a").to_h { |link| [link.text.strip, link["href"]] }
    ijcai_links = cards[1].css(".publication-links a").to_h { |link| [link.text.strip, link["href"]] }
    assert_equal "https://github.com/ScottBlizzard/OV-OrthKD", mm_links["[Project]"]
    refute mm_links.key?("[Code]"), "MM repository has not released code yet"
    assert_equal "https://github.com/ScottBlizzard/orthkd-dr-screening", ijcai_links["[Code]"]
    cards.each { |card| refute_includes card.css(".publication-links a").map(&:text), "[Poster]" }

    css = File.read(File.join(ROOT, "site/assets/css/global.css"))
    assert_match(/\.publication-authors sup\s*\{[^}]*font-size:\s*0\.9em;[^}]*font-weight:\s*900;/m, css)
  end

  def test_all_publication_surfaces_use_the_same_order_and_images
      doc = Nokogiri::HTML(File.read(File.join(ROOT, "index.html")))
      entries = publications
      cards = doc.css(".publication-card")
      assert_equal entries.map { |entry| entry.fetch("title") }, cards.map { |card| card.at_css("h3").text }
      assert_nil cards.index { |card| card["data-submission"] }
      cards.zip(entries).each do |card, entry|
          image = card.at_css("img.publication-cover")
          refute_nil image, "Missing figure for #{entry['title']}"
          assert_equal entry.fetch("cover"), image["src"]
          assert_nil card.at_css(".fa-file-alt"), "File icon should not replace a paper figure"
          assert_equal entry["display_credit"], card.at_css(".publication-authors")&.text&.strip if entry["preprint"]
          assert_includes card.at_css(".publication-venue").text, "Preprint 2026" if entry["preprint"]
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
    assert_equal %w[all accepted], buttons.map { |button| button["data-filter"] }
    assert_equal %w[true false], buttons.map { |button| button["aria-pressed"] }
    assert_equal 3, doc.css(".publication-card").length
    assert_equal 3, doc.css('.publication-card[data-status="accepted"]').length
    assert_empty doc.css('.publication-card[data-status="preprint"]')
    assert_empty doc.css(".publication-card[hidden]")
    assert_equal "3 papers", doc.at_css(".publication-count").text.strip
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
