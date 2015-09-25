let s:script_path = expand('<sfile>:p')

function! s:calculate_github_url(line1, line2, args)
  if !has('ruby')
    echo "Your vim is not compiled as has('ruby'). Try building vim with ruby support."
    return
  endif

ruby <<EOS
require "uri"

class GithubUrl
  def initialize(start_line, end_line, file_name)
    @start_line = start_line
    @end_line   = end_line
    @file_name  = file_name
  end

  def generate(*args)
    status = blame_mode?(args) ? 'blame' : 'blob'
    host, path = parse_remote_origin
    revision   = args.first || current_head
    revision   = to_revision(revision) if is_branch?(revision)

    trimmed_path = path.gsub(/^\//, "").gsub(/\.git$/, "")
    user = trimmed_path.split("/").first
    repo = trimmed_path.split("/").last

    File.join("#{scheme}://#{host}", user, repo, status, revision, "#{file_path}#{line_anchor}")
  end

  private

  def blame_mode?(args)
    args.delete('-b') || args.delete('--blame')
  end

  def parse_remote_origin
    if remote_origin =~ /^(http|https|ssh):\/\//
      uri = URI.parse(remote_origin)
      [uri.host, uri.path]
    elsif remote_origin =~ /^[^:\/]+:\/?[^:\/]+\/[^:\/]+$/
      host, path = remote_origin.split(":")
      [host.split("@").last, path]
    else
      raise "Not supported origin url: #{remote_origin}"
    end
  end

  def scheme
    remote_origin.split(':').first == 'http' ? 'http' : 'https'
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
EOS

  return url
endfunction

function! OpenGithub(line1, line2, ...)
  let url = s:calculate_github_url(a:line1, a:line2, a:000)
  return s:open_browser(url)
endfunction

function! CopyGithub(line1, line2, ...)
  let url = s:calculate_github_url(a:line1, a:line2, a:000)
  return s:copy_to_clipboard(url)
endfunction

command! -nargs=* -range OpenGithub :call OpenGithub(<line1>, <line2>, <f-args>)
command! -nargs=* -range CopyGithub :call CopyGithub(<line1>, <line2>, <f-args>)

" Thanks to https://github.com/mattn/gist-vim
function! s:get_browser_command()
  let browser_command = get(g:, 'browser_command', '')
  if browser_command == ''
    if has('win32') || has('win64')
      let browser_command = '!start rundll32 url.dll,FileProtocolHandler %URL%'
    elseif has('mac') || has('macunix') || has('gui_macvim') || system('uname') =~? '^darwin'
      let browser_command = 'open %URL%'
    elseif executable('xdg-open')
      let browser_command = 'xdg-open %URL%'
    elseif executable('firefox')
      let browser_command = 'firefox %URL% &'
    else
      let browser_command = ''
    endif
  endif
  return browser_command
endfunction

function! s:open_browser(url)
  let cmd = s:get_browser_command()
  if len(cmd) == 0
    redraw
    echohl WarningMsg
    echo "It seems that you don't have general web browser. Open URL below."
    echohl None
    echo a:url
    return
  endif
  if cmd =~ '^!'
    let cmd = substitute(cmd, '%URL%', '\=shellescape(a:url)', 'g')
    silent! exec cmd
  elseif cmd =~ '^:[A-Z]'
    let cmd = substitute(cmd, '%URL%', '\=a:url', 'g')
    exec cmd
  else
    let cmd = substitute(cmd, '%URL%', '\=shellescape(a:url)', 'g')
    call system(cmd)
  endif
endfunction

" Thanks to https://github.com/tonchis/vim-to-github
function! s:copy_to_clipboard(url)
  if exists('g:to_github_clip_command')
    call system(g:to_github_clip_command, a:url)
  elseif system('which pbcopy') || !v:shell_error
    call system('pbcopy', a:url)
  elseif has('unix') && !has('xterm_clipboard')
    let @" = a:url
  else
    let @+ = a:url
  endif

  echo "Copied " . a:url . " to clipboard"
endfunction
