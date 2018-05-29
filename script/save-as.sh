#!/usr/bin/env bash
jar_path=$1
puml_path=$2
image_type=$3

target_path=$4
save_path=$5

java -Dapple.awt.UIElement=true -jar "$jar_path" "$puml_path" -t$image_type
cp "$target_path" "$save_path"
