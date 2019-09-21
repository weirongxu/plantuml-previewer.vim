command! PlantumlStart call plantuml_previewer#start()
command! PlantumlOpen call plantuml_previewer#open()
command! PlantumlStop call plantuml_previewer#stop()
command! -nargs=* -complete=file PlantumlSave call plantuml_previewer#save_as(<f-args>)
