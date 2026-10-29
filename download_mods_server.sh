#!/usr/bin/env bash

# Define multiple mod list URLs here
MODS_LIST_URLS=(
    "https://raw.githubusercontent.com/0000xFFFF/minecraft-mods/refs/heads/master/list_mods_both.txt"
    "https://raw.githubusercontent.com/0000xFFFF/minecraft-mods/refs/heads/master/list_mods_server_only.txt"
)

# Global flag: Set to true to skip files that already exist locally, false to overwrite/re-download
SKIP_EXISTING=true

# Create a temporary file for the mod lists
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

for url in "${MODS_LIST_URLS[@]}"; do
    echo "Fetching mods list from $url..."
    if ! curl -sSL -o "$TEMP_FILE" "$url"; then
        echo "Error: Failed to download mods list from $url"
        continue
    fi

    echo "Processing downloads from $url..."

    while IFS= read -r line || [ -n "$line" ]; do
        line=$(echo "$line" | xargs)
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # Strip query parameters, extract filename, and decode %2B to +
        clean_url="${line%%\?*}"
        filename="${clean_url##*/}"
        filename="${filename//\%2B/+}"

        # Check if the file already exists and skip if enabled
        if [ "$SKIP_EXISTING" = true ] && [ -f "$filename" ]; then
            echo "  [SKIP] $filename already exists."
            continue
        fi

        echo "Downloading: $filename"
        if curl -L -s --show-error -o "$filename" "$line"; then
            echo "  [OK] Saved to $filename"
        else
            echo "  [ERROR] Failed to download $filename"
        fi
    done < "$TEMP_FILE"
done

echo "Done!"

