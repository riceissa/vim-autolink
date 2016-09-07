if exists('g:loaded_autolink')
  finish
endif
let g:loaded_autolink = 1

if !exists('g:autolink_executable')
  let g:autolink_executable = 'autolink'
endif

if !exists('g:autolink_download_provider')
  let g:autolink_download_provider = 'wget --quiet -O -'
endif

if executable(g:autolink_executable) && has('clipboard')
  function! PasteLink(fmt, flags)
    " We use shellescape() later anyway, but some markup languages get
    " confused about quotes and backslashes in the URL.
    let link = substitute(@+, '"', '%22', 'g')
    let link = substitute(link, "'", "%27", "g")
    let link = substitute(link, '\', "%5C", "g")
    if a:fmt ==? ''
      let ftype = "text"
    else
      let ftype = a:fmt
    endif
    let command = g:autolink_download_provider . ' ' . shellescape(link) .
      \ " | " . g:autolink_executable . " --filetype " . ftype .
      \ " " . shellescape(link) . " " . a:flags
    let out = system(command)
    " I think Vim stores '\n' as NULL so we can't filter out '\d0'. Try the
    " following:
    "   let @a = substitute("echo 'a\rb\nc'", '[\d0]', '', 'g')
    " Now check with ':reg a' to see that the linefeed has disappeared.
    return substitute(out, '[\d1-\d9\d11\d12\d14-\d31\d127]', '', 'g')
  endfunction

  " Break up the undo first in case the output is messed up.  The actual
  " pasting mapping is from $VIMRUNTIME/autoload/paste.vim.
  inoremap <C-G><C-L> <C-G>ux<Esc>"=PasteLink(&filetype, "").'xy'<CR>gPFx"_2x"_s
  inoremap <C-G><C-R> <C-G>ux<Esc>"=PasteLink(&filetype, "-C -R").'xy'<CR>gPFx"_2x"_s
endif
