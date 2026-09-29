#!/usr/bin/env ruby
# Compile from the canonical cv/ sources; keep auxiliary files out of cv/.
require "fileutils"

root = File.expand_path("..", __dir__)
documents = {
  "cheng-chen-cv" => "pdflatex",
  "cheng-chen-cv-zh" => "xelatex",
  "cheng-chen-cv-legacy" => "xelatex",
  "cheng-chen-resume-photo-zh" => "xelatex",
  "cheng-chen-personal-statement-zh" => "xelatex",
  "cheng-chen-additional-profile-zh" => "xelatex"
}.freeze
requested = ARGV.empty? ? documents.keys : ARGV.map { |name| name.delete_suffix(".tex") }
unknown = requested - documents.keys
abort "Unknown CV: #{unknown.join(', ')}" unless unknown.empty?

requested.each do |name|
  build = File.join(root, ".build", "cv", name)
  FileUtils.mkdir_p(build)
  log = File.join(build, "build.log")
  File.open(log, "w") do |output|
    2.times do
      ok = system(documents.fetch(name), "-interaction=nonstopmode", "-halt-on-error",
                  "-output-directory=#{build}", "#{name}.tex",
                  chdir: File.join(root, "cv"), out: output, err: [:child, :out])
      abort "Compilation failed; see #{log}" unless ok
    end
  end
  pdf = File.join(build, "#{name}.pdf")
  abort "Missing or empty PDF: #{pdf}" unless File.size?(pdf)
  # Legacy remains available in .build/cv/ without adding another download.
  FileUtils.cp(pdf, File.join(root, "cv", "#{name}.pdf")) unless name.end_with?("-legacy")

  puts "Built #{name}"
end
