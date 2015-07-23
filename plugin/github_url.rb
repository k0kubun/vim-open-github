require "uri"

class GithubUrl
  def initialize(start_line, end_line, file_name)
    @start_line = start_line
    @end_line   = end_line
    @file_name  = file_name
  end

  def generate(*args)
    host, path = parse_remote_origin
    revision   = args.first || current_branch

    trimmed_path = path.gsub(/^\//, "").gsub(/\.git$/, "")
    user = trimmed_path.split("/").first
    repo = trimmed_path.split("/").last

    "https://#{host}/#{user}/#{repo}/blob/#{revision}/#{file_path}#{line_anchor}"
  end

  private

  def parse_remote_origin
    if remote_origin =~ /^https:\/\//
      uri = URI.parse(remote_origin)
      [uri.host, uri.path]
    elsif remote_origin =~ /^[^:\/]+:\/?[^:\/]+\/[^:\/]+$/
      host, path = remote_origin.split(":")
      [host.split("@").last, path]
    else
      raise "Not supported origin url: #{remote_origin}"
    end
  end

  def file_path
    @file_name.gsub("#{repository_root}/", "")
  end

  def line_anchor
    if @start_line == @end_line
      "#L#{@start_line}"
    else
      "#L#{@start_line}-L#{@end_line}"
    end
  end

  def remote_origin
    @remote_origin ||= `git config remote.origin.url`.strip
  end

  def repository_root
    `git rev-parse --show-toplevel`.strip
  end

  def current_branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end
end

start_line = VIM.evaluate('a:line1')
end_line   = VIM.evaluate('a:line2')
file_name  = VIM.evaluate('bufname("%")')
args       = VIM.evaluate('a:args')

url = GithubUrl.new(start_line, end_line, file_name).generate(*args)
VIM.command("let url = '#{url}'")
