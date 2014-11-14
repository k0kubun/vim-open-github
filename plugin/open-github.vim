let s:script_path = expand('<sfile>:p')

function! s:calculate_github_url(line1, line2, args)
  if !has('ruby')
    echo "Your vim is not compiled as has('ruby'). Try building vim with ruby support."
    return
  endif

ruby <<EOS
  class UrlGenerator
    def initialize(start_line, end_line, file_name)
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
