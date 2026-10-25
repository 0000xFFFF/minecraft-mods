#!/usr/bin/env bash
set -x
sort -u append_mods_both.txt append_mods_server_only.txt> mods_server.txt
