#!/bin/bash
while IFS= read -r url || [ -n "$url" ]; do
    [[ -z "$url" || "$url" =~ ^# ]] && continue
    curl -L -O "$url"
done < "client_mods.txt"
