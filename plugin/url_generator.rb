class UrlGenerator
  def initialize(start_line, end_line, file_name)
    @start_line = start_line
    @end_line   = end_line
    @file_name  = file_name
  end

  def generate(usernae = nil, repo = nil)
    "https://github.com"
  end
end

start_line = VIM.evaluate('a:line1')
end_line   = VIM.evaluate('a:line2')
file_name  = VIM.evaluate('bufname("%")')
args       = VIM.evaluate('a:args')

url = UrlGenerator.new(start_line, end_line, file_name).generate(*args)
VIM.command("let url = '#{url}'")
