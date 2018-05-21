set jar_path=%1
set puml_path=%2
set timestamp=%3
set update_js_path=%4
java -Dapple.awt.UIElement=true -jar "%jar_path%" "%puml_path%" -tsvg
echo window.updateDiagramURL('%timestamp%') > "%update_js_path%"
