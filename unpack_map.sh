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
grep -Ei '\.map' "$urlFile" > "$tempFolder/urls.txt"

# Download .map files
while IFS= read -r url; do
    filename=$(echo "$url" | awk -F'://' '{print $2}' | sed 's/[\/:?&=]/-/g')
    wget -q -O "$mapFolder/$filename" "$url"
done < "$tempFolder/urls.txt"

files=()

# Process each downloaded .map file
find "$mapFolder" -type f -name "*.map" | while IFS= read -r mapFile; do
    # Check if file is valid JSON and has required keys
    if ! jq -e '.sources and .sourcesContent' "$mapFile" > /dev/null 2>&1; then
        echo "Skipping invalid or incomplete map file: $mapFile"
        continue
    fi

    sources_count=$(jq '.sources | length' "$mapFile")
    content_count=$(jq '.sourcesContent | length' "$mapFile")

    # Check if array lengths match
    if [ "$sources_count" -ne "$content_count" ]; then
        echo "Mismatch in sources and sourcesContent in $mapFile, skipping..."
        continue
    fi

    for ((i=0; i<sources_count; i++)); do
        src=$(jq -r ".sources[$i]" "$mapFile")
        content=$(jq -r ".sourcesContent[$i]" "$mapFile")

        # Skip empty content
        if [ -z "$content" ] || [ "$content" = "null" ]; then
            continue
        fi

        # Sanitize and write file
        safe_src=$(echo "$src" | sed 's#^\./##')  # remove leading ./
        target_dir="$outputFolder/$(dirname "$safe_src")"
        mkdir -p "$target_dir"

        target_file="$target_dir/$(basename "$safe_src")"
        echo "$content" > "$target_file"
        files+=("$target_file")
    done
done

# Print extracted files
if [ "${#files[@]}" -eq 0 ]; then
    echo "No source files were extracted."
else
    echo "Extracted source files:"
    for i in "${!files[@]}"; do
        echo "  [$i] ${files[$i]}"
    done
fi

# Cleanup
rm -rf "$tempFolder"
