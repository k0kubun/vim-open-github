class GithubUrl
  def initialize(start_line, end_line, file_name)
    @start_line = start_line
    @end_line   = end_line
    @file_name  = file_name
  end

  def generate(username = nil, repo = nil)
    "https://github.com"
  end

  private

  def repository_root
    `git rev-parse --top-level`
  end

  def remote_origin
    `git config remote.origin.url`
  end

  def current_branch
    `git rev-parse --abbrev-ref HEAD`
  end
end

start_line = VIM.evaluate('a:line1')
end_line   = VIM.evaluate('a:line2')
file_name  = VIM.evaluate('bufname("%")')
args       = VIM.evaluate('a:args')

url = GithubUrl.new(start_line, end_line, file_name).generate(*args)
VIM.command("let url = '#{url}'")
