#!/usr/bin/env ruby
# Preview by default. --apply moves only the listed clutter into a local archive.
require "fileutils"
require "json"
require "time"

root = File.expand_path("..", __dir__)
Dir.chdir(root)
abort "Usage: ruby tools/organize_workspace.rb [--apply]" unless (ARGV - ["--apply"]).empty?

intermediates = /\.(?:aux|bcf|blg|fdb_latexmk|fls|log|out|run\.xml|synctex\.gz|toc|xdv)\z/
candidates = ["cv", "papers", "academic-homepage/cv", "academic-homepage/papers"].flat_map do |dir|
  Dir.glob("#{dir}/**/*").select { |path| File.file?(path) && path.match?(intermediates) }
end
candidates += %w[texput.log output academic-homepage/output academic-homepage/_site cv/rubbish cv/cheng-chen-cv-legacy.pdf].select { |p| File.exist?(p) }

# Compare bytes directly; preserve every copy in the archive, even when identical.
%w[2025_AIC_Award.pdf 2025_Embedded_Systems.png].each do |name|
  canonical = "awards/#{name}"
  [name, "academic-homepage/#{name}"].each do |copy|
    next unless File.file?(copy) && File.file?(canonical)
    if FileUtils.compare_file(copy, canonical)
      candidates << copy
    else
      warn "Keeping differing award copy: #{copy}"
    end
  end
end
candidates = candidates.uniq.sort.reject do |path|
  candidates.any? { |other| path.start_with?("#{other}/") }
end

if ARGV.include?("--apply") && !candidates.empty?
  archive = File.join(".local", "archive", Time.now.strftime("%Y%m%d-%H%M%S-%6N"))
  FileUtils.mkdir_p(archive)
  candidates.each do |path|
    target = File.join(archive, path)
    FileUtils.mkdir_p(File.dirname(target))
    FileUtils.mv(path, target)
  end
  File.write(File.join(archive, "manifest.json"), JSON.pretty_generate({
    "created_at" => Time.now.iso8601,
    "original_paths" => candidates,
    "restore" => "Each archived file or directory retains its original relative path."
  }) + "\n")
  puts "Archived #{candidates.length} items in #{archive}; nothing deleted."
else
  puts candidates
  puts "#{candidates.length} items. Run with --apply to archive."
end
