#!/usr/bin/env bash
set -x
sort -u append_mods_both.txt append_mods_client_only.txt > mods_client.txt
