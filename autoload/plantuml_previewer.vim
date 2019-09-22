let s:Process = vital#plantuml_previewer#new().import('System.Process')
let s:Job = vital#plantuml_previewer#new().import('System.Job')
let s:is_win = has('win32') || has('win64') || has('win95')

let s:base_path = fnameescape(expand("<sfile>:p:h")) . '/..'

let s:default_jar_path = s:base_path . '/lib/plantuml.jar'

let s:tmp_path = s:base_path . '/tmp'

let s:save_as_script_path = s:base_path . '/script/save-as' . (s:is_win ? '.cmd' : '.sh')
let s:save_as_tmp_puml_path = s:tmp_path . '/tmp.puml'

let s:update_viewer_script_path = s:base_path . '/script/update-viewer' . (s:is_win ? '.cmd' : '.sh')

function! plantuml_previewer#start() "{{{
  if !executable('java')
    echoerr 'require java'
    return
  endif
  let viewer_path = s:viewer_path()
  if !isdirectory(viewer_path) && !filereadable(viewer_path)
    call plantuml_previewer#copy_viewer_directory()
  endif
  call delete(s:viewer_tmp_puml_path())
  call delete(s:viewer_tmp_svg_path())
  call plantuml_previewer#refresh()
  augroup plantuml_previewer
    autocmd!
    autocmd BufWritePost <buffer> call plantuml_previewer#refresh()
  augroup END
endfunction "}}}

function! plantuml_previewer#open() "{{{
  if !exists('*OpenBrowser')
    echoerr 'require openbrowser'
    return
  endif
  call plantuml_previewer#start()
  call OpenBrowser(s:viewer_html_path())
endfunction }}}

function! plantuml_previewer#stop() "{{{
  augroup plantuml_previewer
    autocmd!
  augroup END
endfunction "}}}

function! s:is_zero(val) "{{{
  return type(a:val) == type(0) && a:val == 0
endfunction "}}}

function! plantuml_previewer#copy_viewer_directory() "{{{
  let viewer_path = s:viewer_path()
  let default_viewer_path = plantuml_previewer#default_viewer_path()
  if viewer_path != default_viewer_path
    if s:is_win
      call system('xcopy ' . default_viewer_path . ' ' . g:plantuml_previewer#viewer_path . ' /O /X /E /H /K')
    else
      call system('cp -r ' . default_viewer_path . ' ' . g:plantuml_previewer#viewer_path)
    endif
    echom 'copy ' . default_viewer_path . ' -> ' . viewer_path
  endif
endfunction "}}}

function! plantuml_previewer#default_viewer_path() "{{{
  return s:base_path . '/viewer'
endfunction "}}}

function! s:viewer_path() "{{{
  let path = get(g:, 'plantuml_previewer#viewer_path', 0)
  return s:is_zero(path) ? plantuml_previewer#default_viewer_path() : fnameescape(path)
endfunction "}}}

function! s:viewer_tmp_puml_path() "{{{
  return s:viewer_path() . '/tmp.puml'
endfunction "}}}

function! s:viewer_tmp_svg_path() "{{{
  return s:viewer_path() . '/tmp.svg'
endfunction "}}}

function! s:viewer_tmp_js_path() "{{{
  return s:viewer_path() . '/tmp.js'
endfunction "}}}

function! s:viewer_html_path() "{{{
  return s:viewer_path() . '/index.html'
endfunction "}}}

function! s:jar_path() "{{{
  let path = get(g:, 'plantuml_previewer#plantuml_jar_path', 0)
  return s:is_zero(path) ? s:default_jar_path : path
endfunction "}}}

function! s:save_format() "{{{
  return get(g:, 'plantuml_previewer#save_format', 'png')
endfunction "}}}

function! s:ext_to_fmt(ext) "{{{
  return a:ext == 'tex' ? 'latex' : a:ext
endfunction "}}}

function! s:fmt_to_ext(fmt) "{{{
  return a:fmt == 'latex' ? 'tex' : a:fmt
endfunction "}}}

function! s:run_in_background(cmd) "{{{
  if s:Job.is_available()
    call s:Job.start(a:cmd)
  else
    try
      call s:Process.execute(a:cmd, {
            \ 'background': 1,
            \})
    catch
      call s:Process.execute(a:cmd)
    endtry
  endif
endfunction "}}}

function! plantuml_previewer#refresh() "{{{
  let content = getline(1, '$')
  call writefile(content, s:viewer_tmp_puml_path())
  let cmd = [
        \ s:update_viewer_script_path,
        \ s:jar_path(),
        \ s:viewer_tmp_puml_path(),
        \ 'svg',
        \ localtime(),
        \ s:viewer_tmp_js_path(),
        \ ]
  call s:run_in_background(cmd)
endfunction "}}}

function! plantuml_previewer#save_as(...) "{{{
  let save_path = get(a:000, 0, 0)
  let target_format = get(a:000, 1, 0)
  if s:is_zero(save_path)
    let source_name = expand('%:t:r')
    let save_path = printf("%s.%s", source_name, s:fmt_to_ext(s:save_format()))
  else
    let save_path = fnamemodify(save_path, ':p')
  endif
  if s:is_zero(target_format)
    let ext = fnamemodify(save_path, ':e')
    let target_format = ext == '' ? s:save_format() : s:ext_to_fmt(ext)
  endif
  let target_path = printf("%s.%s", fnamemodify(s:save_as_tmp_puml_path, ':p:r'), target_format)
  let content = getline(1,'$')
  call mkdir(s:tmp_path, 'p')
  call writefile(content, s:save_as_tmp_puml_path)
  call mkdir(fnamemodify(save_path, ':p:h'), 'p')
  let cmd = [
        \ s:save_as_script_path,
        \ s:jar_path(),
        \ s:save_as_tmp_puml_path,
        \ target_format,
        \ target_path,
        \ save_path,
        \ ]
  call s:run_in_background(cmd)
endfunction "}}}
