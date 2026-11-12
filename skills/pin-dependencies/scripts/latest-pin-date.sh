#!/usr/bin/env bash
# Prints the newest apt/Alpine snapshot, optionally the newest one before a cutoff date.
# Usage: latest-pin-date.sh [--before YYYY-MM-DD]
set -euo pipefail

before=""
if [[ "${1:-}" == "--before" ]]; then
    before="${2:?--before needs a date, e.g. 2026-07-24}"
fi

curl -fsS --max-time 30 http://debmirror.stablebuild.com/ \
    | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' \
    | sort -u \
    | awk -v before="$before" 'before == "" || $0 < before' \
    | tail -n 1
