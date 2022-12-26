#!/usr/bin/env bash
jar_path=$1

puml_src_path=$2
output_dir_path=$3
output_path=$4
save_path=$5
image_type=$6
include_path=$7

java -Dapple.awt.UIElement=true -Djava.awt.headless=true -Dplantuml.include.path="$include_path" -jar "$jar_path" "$puml_src_path" -t$image_type -o "$save_path"
