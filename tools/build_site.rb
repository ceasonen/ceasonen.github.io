#!/usr/bin/env ruby
# Jekyll source lives in academic-homepage/; GitHub Pages serves the repo root.
require "fileutils"

root = File.expand_path("..", __dir__)
source = File.join(root, "academic-homepage")
destination = File.join(root, ".build", "site")
FileUtils.mkdir_p(destination)
ok = system("bundle", "exec", "jekyll", "build", "--destination", destination, chdir: source)
abort "Jekyll build failed" unless ok

# Never mirror the entire build tree into the repository: it may contain local files.
pages = %w[index.html publications.html news.html intern.html awards.html 404.html]
pages += Dir.glob(File.join(destination, "[0-9][0-9][0-9][0-9]", "**", "*.html"))
            .map { |path| path.delete_prefix("#{destination}/") }
pages.each do |relative|
  input = File.join(destination, relative)
  abort "Missing generated page: #{relative}" unless File.file?(input)
end
pages.each do |relative|
  output = File.join(root, relative)
  FileUtils.mkdir_p(File.dirname(output))
  File.write(output, File.read(File.join(destination, relative)).gsub(/[ \t]+$/, ""))
end

assets = Dir.glob(File.join(destination, "assets", "**", "*")).select { |path| File.file?(path) }
assets << File.join(destination, "favicon.svg")
assets.each do |input|
  output = File.join(root, input.delete_prefix("#{destination}/"))
  FileUtils.mkdir_p(File.dirname(output))
  FileUtils.cp(input, output)
end
puts "Updated #{pages.length} public pages and #{assets.length} assets."
