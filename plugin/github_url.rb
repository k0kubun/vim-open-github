require "uri"

class GithubUrl
  def initialize(start_line, end_line, file_name)
    @start_line = start_line
    @end_line   = end_line
    @file_name  = file_name
  end

  def generate(*args)
    host, path = parse_remote_origin
    revision   = args.first || current_head
    revision   = master_revision if is_branch?(revision)

    trimmed_path = path.gsub(/^\//, "").gsub(/\.git$/, "")
    user = trimmed_path.split("/").first
    repo = trimmed_path.split("/").last

    File.join("https://#{host}", user, repo, 'blob', revision, "#{file_path}#{line_anchor}")
  end

  private

  def parse_remote_origin
    if remote_origin =~ /^(https|ssh):\/\//
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
    current_dir = `pwd`.strip
    full_path =
      if @file_name.include?(current_dir)
        @file_name
      else 
        File.join(current_dir, @file_name)
      end
    full_path.gsub(/^#{repository_root}/, "")
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

  def current_head
    ref = `git rev-parse --abbrev-ref HEAD`.strip
    return ref if ref != 'HEAD'

    `git describe`.strip
  end

  def master_revision
    `git rev-parse master`.strip
  end

  def is_branch?(revision)
    branches.include?(revision)
  end

  def to_revision(branch)
    `git rev-parse #{branch}`.strip
  end

  def branches
    `git branch`.split("\n").map { |b| b.gsub(/^\*/, '').strip }
  end
end

start_line = VIM.evaluate('a:line1')
end_line   = VIM.evaluate('a:line2')
file_name  = VIM.evaluate('bufname("%")')
args       = VIM.evaluate('a:args')

url = GithubUrl.new(start_line, end_line, file_name).generate(*args)
VIM.command("let url = '#{url}'")
