let s:P = vital#plantuml_previewer#new().import('System.Process')
let s:is_win = has('win32') || has('win64') || has('win95')

let s:base_path = expand("<sfile>:p:h") . '/..'
let s:update_uml_script_path = s:base_path . '/script/update-uml' . (s:is_win ? '.cmd' : '.sh')
let s:jar_path = s:base_path . '/lib/plantuml.jar'
let s:viewer_base_path = s:base_path . '/viewer'
let s:tmp_puml_path = s:viewer_base_path . '/tmp.puml'
let s:tmp_svg_path = s:viewer_base_path . '/tmp.svg'
let s:tmp_js_path = s:viewer_base_path . '/tmp.js'
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
  call delete(s:tmp_puml_path)
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

function! plantuml_previewer#refresh() "{{{
  let content = getline(1,'$')
  call writefile(content, s:tmp_puml_path)
  let cmd = [s:update_uml_script_path, s:jar_path, s:tmp_puml_path, localtime(), s:tmp_js_path]
  let result = s:P.execute(cmd, {
        \ 'background': 1,
        \})
endfunction "}}}
