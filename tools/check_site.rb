#!/usr/bin/env ruby
# Check local links in the published HTML; external URLs are not fetched.
require "cgi"
require "uri"

root = File.expand_path("..", __dir__)
pages = %w[index.html publications.html projects.html news.html intern.html awards.html 404.html cv/index.html offer-pilot/index.html deep-research/index.html]
pages += Dir.glob(File.join(root, "[0-9][0-9][0-9][0-9]", "**", "*.html"))
            .map { |path| path.delete_prefix("#{root}/") }
errors = []
checked = 0
pages.each do |relative|
  page = File.join(root, relative)
  unless File.file?(page)
    errors << "Missing page: #{relative}"
    next
  end
  File.read(page).scan(/(?:href|src|data)\s*=\s*["']([^"']+)["']/i).flatten.each do |raw|
    url = CGI.unescapeHTML(raw)
    next if url.start_with?("#", "//") || url.match?(/\A[a-z][a-z0-9+.-]*:/i)
    path = URI::DEFAULT_PARSER.unescape(url.split(/[?#]/, 2).first.to_s)
    next if path.empty?
    target = if path.start_with?("/")
               File.expand_path(path.delete_prefix("/"), root)
             else
               File.expand_path(path, File.dirname(page))
             end
    candidates = [target, "#{target}.html", File.join(target, "index.html")]
    checked += 1
    errors << "#{relative}: #{raw}" unless candidates.any? { |candidate| File.file?(candidate) }
  end
end
abort "Broken local links:\n#{errors.join("\n")}" unless errors.empty?
puts "#{pages.length} pages checked; #{checked} local links resolve."
