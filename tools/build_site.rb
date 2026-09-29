#!/usr/bin/env ruby
# Edit site/ only; GitHub Pages serves generated files at the repository root.
require "fileutils"

root = File.expand_path("..", __dir__)
source = File.join(root, "site")
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
  notice = "<!-- GENERATED FILE: edit site/ sources, then run ruby tools/website.rb build. Do not edit this copy. -->\n"
  File.write(output, notice + File.read(File.join(destination, relative)).gsub(/[ \t]+$/, ""))
end

assets = Dir.glob(File.join(destination, "assets", "**", "*")).select { |path| File.file?(path) }
assets << File.join(destination, "favicon.svg")
assets.each do |input|
  output = File.join(root, input.delete_prefix("#{destination}/"))
  FileUtils.mkdir_p(File.dirname(output))
  FileUtils.cp(input, output)
end

# Copy only explicitly public downloads into the preview, after every build.
# Never copy cv/ sources, papers/ working trees or .local/ into the server root.
FileUtils.mkdir_p(File.join(destination, "cv"))
%w[index.html cheng-chen-cv.pdf].each do |file|
  FileUtils.cp(File.join(root, "cv", file), File.join(destination, "cv", file))
end
puts "Updated #{pages.length} public pages and #{assets.length} assets."
