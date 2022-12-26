#!/usr/bin/env bash

jar_path=$1

puml_src_path=$2
output_dir_path=$3
output_path=$4
final_path=$5
image_type=$6

timestamp=$7
update_js_path=$8
include_path=$9

java -Dapple.awt.UIElement=true -Djava.awt.headless=true -Dplantuml.include.path="$include_path" -jar "$jar_path" "$puml_src_path" -t$image_type -o "$final_path"
echo "window.updateDiagramURL('$timestamp')" > "$update_js_path"
