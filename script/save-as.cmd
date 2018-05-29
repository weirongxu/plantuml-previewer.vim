set jar_path=%1
set puml_path=%2
set image_type=%3

set target_path=%4
set save_path=%5

java -Dapple.awt.UIElement=true -jar "%jar_path%" "%puml_path%" -t%image_type%
copy "%target_path%" "%save_path%"
