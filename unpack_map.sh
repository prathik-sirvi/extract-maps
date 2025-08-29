#!/bin/bash

# Check for two arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <folder_with_map_files> <output_base_folder>"
    exit 1
fi

INPUT_FOLDER="$1"
OUTPUT_BASE="$2"

# Check if input folder exists
if [ ! -d "$INPUT_FOLDER" ]; then
    echo "Error: Folder '$INPUT_FOLDER' does not exist."
    exit 1
fi

# Create output folder if it doesn't exist
mkdir -p "$OUTPUT_BASE"

# Flag to check if any map files exist
found_map_files=false

# Loop through all .map files
for mapfile in "$INPUT_FOLDER"/*.map; do
    [ -e "$mapfile" ] || continue

    found_map_files=true

    echo "Processing: $mapfile"

    # Dump all sources into shared OUTPUT_BASE
    php ~/tools/extract-maps.php "$mapfile" "$OUTPUT_BASE"

    echo "Extracted sources to: $OUTPUT_BASE"
    echo "---------------------------------------"
done

if [ "$found_map_files" = false ]; then
    echo "No .map files found in '$INPUT_FOLDER'"
    exit 0
fi
