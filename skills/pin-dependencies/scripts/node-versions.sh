#!/usr/bin/env bash
# Lists the Node.js versions of one major release in a snapshot, for `sb-apt.sh install-node-js`.
# Usage: node-versions.sh <major, e.g. 20> <APT_PIN_DATE, e.g. 2026-11-11T08:40:01Z>
set -euo pipefail

major="${1:?usage: node-versions.sh <major> <APT_PIN_DATE>}"
pin_date="${2:?usage: node-versions.sh <major> <APT_PIN_DATE>}"

curl -fsS --max-time 30 "http://debmirror.stablebuild.com/${pin_date}/deb.nodesource.com/node_${major}.x/pool/main/n/nodejs/" \
    | grep -oE "nodejs_${major}\.[0-9]+\.[0-9]+-1nodesource1_amd64\.deb" \
    | sed -E 's/^nodejs_([0-9.]+)-.*/\1/' \
    | sort -uV
