#!/usr/bin/env ruby
# One entry point, usable from any working directory. Never stages or pushes files.
require "rbconfig"

root = File.expand_path("..", __dir__)
Dir.chdir(root)
ruby = RbConfig.ruby
command = ARGV.shift || "help"

def run!(*args)
  abort "Command failed: #{args.join(' ')}" unless system(*args)
end

case command
when "help", "--help", "-h"
  puts <<~HELP
    网站维护（源码：site/；简历：cv/）
    ruby tools/website.rb build    构建网站并检查链接与内容
    ruby tools/website.rb check    检查已生成页面与维护入口
    ruby tools/website.rb preview  构建并本地预览：http://127.0.0.1:4000
    ruby tools/website.rb cv       编译全部 CV；可追加文档名只编译指定版本
    修改位置和发布步骤：README.md、docs/editing-guide.md
    所有命令均不会自动 git add、commit 或 push。
  HELP
when "build", "check", "preview"
  abort "Unexpected arguments: #{ARGV.join(' ')}" unless ARGV.empty?
  run!(ruby, "tools/build_site.rb") unless command == "check"
  run!(ruby, "tools/check_site.rb")
  Dir["tests/*_test.rb"].sort.each { |test| run!(ruby, test) }
  if command == "preview"
    # Serve generated public files only, never the repo or .local/ manuscripts.
    preview = File.join(root, ".build/site")
    puts "Preview: http://127.0.0.1:4000 (Ctrl+C to stop)"
    puts "修改后另开终端运行 ruby tools/website.rb build，再刷新浏览器。"
    STDOUT.flush
    Dir.chdir(File.join(root, "site"))
    exec("bundle", "exec", "jekyll", "serve", "--skip-initial-build", "--no-watch",
         "--destination", preview, "--host", "127.0.0.1", "--port", "4000")
  end
when "cv"
  run!(ruby, "tools/build_cv.rb", *ARGV)
else
  abort "Unknown command: #{command}. Run ruby tools/website.rb help"
end
