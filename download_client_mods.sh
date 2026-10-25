#!/bin/bash

LIST_FILE="client_mods.txt"

if [ ! -f "$LIST_FILE" ]; then
    echo "Error: $LIST_FILE not found!"
    exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | xargs)
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Strip query parameters and extract filename
    clean_url="${line%%\?*}"
    filename="${clean_url##*/}"
    
    # Decode %2B to +
    filename="${filename//\%2B/+}"

    echo "Downloading: $filename"
    curl -L -s --show-error -o "$filename" "$line"
done < "$LIST_FILE"
