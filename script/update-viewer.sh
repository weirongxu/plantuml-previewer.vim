#!/usr/bin/env bash
jar_path=$1
puml_path=$2
image_type=$3

timestamp=$4
update_js_path=$5

java -Dapple.awt.UIElement=true -jar "$jar_path" "$puml_path" -t$image_type
echo "window.updateDiagramURL('$timestamp')" > "$update_js_path"
