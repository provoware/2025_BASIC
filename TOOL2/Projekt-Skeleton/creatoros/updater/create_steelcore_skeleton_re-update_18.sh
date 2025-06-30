#!/usr/bin/env bash
set -euo pipefail
BASE=creatoros/updater
META=$BASE/meta/changes
TARGET=creatoros/tools/smart_mover.py
WRAP=start_smart_sortfix.sh

rm -f "$TARGET" "$WRAP"

TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> "$META/change_18.txt"
echo "Update 18 reverted $TIMESTAMP" >> "$BASE/info-stand.txt"
