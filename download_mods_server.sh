#!/usr/bin/env bash

MODS_LIST_URL="https://raw.githubusercontent.com/0000xFFFF/minecraft-mods/refs/heads/master/mods_server.txt"

# Create a temporary file for the mod list
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

echo "Fetching mods list..."
if ! curl -sSL -o "$TEMP_FILE" "$MODS_LIST_URL"; then
    echo "Error: Failed to download mods.txt from $MODS_LIST_URL"
    exit 1
fi

echo "Starting downloads..."

while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | xargs)
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Strip query parameters, extract filename, and decode %2B to +
    clean_url="${line%%\?*}"
    filename="${clean_url##*/}"
    filename="${filename//\%2B/+}"

    echo "Downloading: $filename"
    if curl -L -s --show-error -o "$filename" "$line"; then
        echo "  [OK] Saved to $filename"
    else
        echo "  [ERROR] Failed to download $filename"
    fi
done < "$TEMP_FILE"

echo "Done!"

