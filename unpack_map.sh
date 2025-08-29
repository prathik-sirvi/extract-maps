#!/bin/bash

if [ "$#" -ne 2 ]; then
    read -p "Enter path to txt file with URLs: " urlFile
    read -p "Enter output folder path: " outputFolder
else
    urlFile="$1"
    outputFolder="$2"
fi

urlFile=$(realpath "$urlFile")
outputFolder="${outputFolder%/}"

if [ ! -f "$urlFile" ]; then
    echo "Error: File '$urlFile' not found."
    exit 1
fi

tempFolder=$(mktemp -d)
mapFolder="$tempFolder/maps"

mkdir -p "$mapFolder"
grep -Ei '\.map' "$urlFile" > tmp

while IFS= read -r url; do
    filename=$(echo $url | awk -F'://' '{print $2}' | sed 's/\//-/g' )
    wget -q -O "$mapFolder/$filename" "$url"
done < tmp

rm tmp

files=()

mapFiles=$(find "$mapFolder" -type f -name "*.map")
if [ -z "$mapFiles" ]; then
    echo "No .map files downloaded."
    exit 0
fi

while IFS= read -r mapFile; do
    sources=$(jq -r '.sources[]' "$mapFile")
    contents=$(jq -r '.sourcesContent[]' "$mapFile")

    IFS=$'\n' read -rd '' -a sources_array <<< "$sources"
    IFS=$'\n' read -rd '' -a contents_array <<< "$contents"

    for i in "${!sources_array[@]}"; do
        src="${sources_array[$i]}"
        content="${contents_array[$i]}"

        target_dir="$outputFolder/$(dirname "$src")"
        mkdir -p "$target_dir"

        target_file="$target_dir/$(basename "$src")"
        echo -n "$content" > "$target_file"

        files+=("$target_file")
    done
done <<< "$mapFiles"

echo "All Source codes have been extracted from map file:"
echo "("
for i in "${!files[@]}"; do
    echo "    [$i] => ${files[$i]}"
done
echo ")"

rm -rf "$tempFolder"
