let s:P = vital#plantuml_previewer#new().import('System.Process')
let s:base_path = expand("<sfile>:p:h") . '/..'
let s:jar_path = s:base_path . '/lib/plantuml.jar'
let s:viewer_base_path = s:base_path . '/viewer'
let s:tmp_puml_path = s:viewer_base_path . '/tmp.puml'
let s:tmp_png_path = s:viewer_base_path . '/tmp.png'
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
  let cmd = ['java', '-Dapple.awt.UIElement=true', '-jar', s:jar_path, s:tmp_puml_path , '-tpng']
  " let cmd = 'java -Dapple.awt.UIElement=true -jar ' . s:jar_path . ' ' . s:tmp_puml_path . ' -tpng'
  " if exists('*jobstart')
  "   call jobstart(cmd)
  " else
  "   call system(cmd)
  " endif
    call s:P.execute(cmd, {"background": 1})
endfunction "}}}
