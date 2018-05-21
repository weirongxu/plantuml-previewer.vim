#!/usr/bin/env bash
jar_path=$1
puml_path=$2
timestamp=$3
update_js_path=$4
java -Dapple.awt.UIElement=true -jar "$jar_path" "$puml_path" -tsvg
echo "window.updateDiagramURL('$timestamp')" > "$update_js_path"
