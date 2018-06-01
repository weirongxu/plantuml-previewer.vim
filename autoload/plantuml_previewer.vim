let s:Process = vital#plantuml_previewer#new().import('System.Process')
let s:Job = vital#plantuml_previewer#new().import('System.Job')
let s:is_win = has('win32') || has('win64') || has('win95')

let s:base_path = expand("<sfile>:p:h") . '/..'

let s:jar_path = s:base_path . '/lib/plantuml.jar'

let s:tmp_path = s:base_path . '/tmp'

let s:save_as_script_path = s:base_path . '/script/save-as' . (s:is_win ? '.cmd' : '.sh')
let s:save_as_tmp_puml_path = s:tmp_path . '/tmp.puml'

let s:update_viewer_script_path = s:base_path . '/script/update-viewer' . (s:is_win ? '.cmd' : '.sh')
let s:viewer_base_path = s:base_path . '/viewer'
let s:viewer_tmp_puml_path = s:viewer_base_path . '/tmp.puml'
let s:viewer_tmp_svg_path = s:viewer_base_path . '/tmp.svg'
let s:viewer_tmp_js_path = s:viewer_base_path . '/tmp.js'
let s:viewer_html_path = s:viewer_base_path . '/dist/index.html'

function! plantuml_previewer#start() "{{{
  if !executable('java')
    echoerr 'require java'
    return
  endif
  if !exists('*OpenBrowser') 
    echoerr 'require openbrowser'
    return
  endif
  call delete(s:viewer_tmp_puml_path)
  call delete(s:viewer_tmp_svg_path)
  call plantuml_previewer#refresh()
  augroup plantuml_previewer
    autocmd!
    autocmd BufWritePost <buffer> call plantuml_previewer#refresh()
  augroup END
  call OpenBrowser(s:viewer_html_path)
endfunction "}}}

function! plantuml_previewer#stop() "{{{
  augroup plantuml_previewer
    autocmd!
  augroup END
endfunction "}}}

function! plantuml_previewer#jar_path() "{{{
  let path = get(g:, 'plantuml_previewer#plantuml_jar_path', 0)
  return path == 0 ? s:jar_path : path
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
  let content = getline(1,'$')
  call writefile(content, s:viewer_tmp_puml_path)
  let cmd = [
        \ s:update_viewer_script_path,
        \ plantuml_previewer#jar_path(),
        \ s:viewer_tmp_puml_path,
        \ 'svg',
        \ localtime(),
        \ s:viewer_tmp_js_path,
        \ ]
  call s:run_in_background(cmd)
endfunction "}}}

function! plantuml_previewer#save_as(save_path) "{{{
  let target_type = get(a:000, 1, 0)
  let save_path = fnamemodify(a:save_path, ':p')
  if target_type == 0
    let ext = fnamemodify(save_path, ':e')
    if ext == ''
      let target_type = 'svg'
    else
      let target_type = ext
    endif
  endif
  let target_path = fnamemodify(s:save_as_tmp_puml_path, ':p:r') . '.' . target_type
  let content = getline(1,'$')
  call mkdir(s:tmp_path, 'p')
  call writefile(content, s:save_as_tmp_puml_path)
  call mkdir(fnamemodify(save_path, ':p:h'), 'p')
  let cmd = [
        \ s:save_as_script_path,
        \ plantuml_previewer#jar_path(),
        \ s:save_as_tmp_puml_path,
        \ target_type,
        \ target_path,
        \ save_path,
        \ ]
  call s:run_in_background(cmd)
endfunction "}}}
