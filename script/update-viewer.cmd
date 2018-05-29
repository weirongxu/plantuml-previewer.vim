set jar_path=%1
set puml_path=%2
set image_type=%3

set timestamp=%4
set update_js_path=%5

java -Dapple.awt.UIElement=true -jar "%jar_path%" "%puml_path%" -t%image_type%
echo window.updateDiagramURL('%timestamp%') > "%update_js_path%"
