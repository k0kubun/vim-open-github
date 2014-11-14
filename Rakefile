#!/usr/bin/env rake

desc "Embed ruby code into vim script"
task :embed do
  vim_src_path  = File.expand_path('../plugin/open-github.vim', __FILE__)
  ruby_src_path = File.expand_path('../plugin/url_generator.rb', __FILE__)

  vim_src  = File.read(vim_src_path)
  ruby_src = File.read(ruby_src_path)

  new_vim_src = vim_src.gsub(/<<EOS.+EOS/m, "<<EOS\n#{ruby_src}EOS")
  File.write(vim_src_path, new_vim_src)
end

desc "Run tests"
task :spec do
  system("bundle exec rspec")
end

task default: :spec
