set java=%1
set jar_path=%2

set puml_src_path=%3
set output_dir_path=%4
set output_path=%5
set save_path=%6
set image_type=%7
set include_path=%8

%java% -Dapple.awt.UIElement=true -Dplantuml.include.path="%include_path%" -jar "%jar_path%" "%puml_src_path%" -t%image_type% -o "%output_dir_path%"
copy "%output_path%" "%save_path%"
