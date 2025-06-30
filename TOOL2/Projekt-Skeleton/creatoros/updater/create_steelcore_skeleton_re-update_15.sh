#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
GUI=$BASE/creatoros/updater/update_manager.py
META=$BASE/meta/changes

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 15 (GUI-Theme)"
  exit 0
fi

rm -f "$GUI"
TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> "$META/change_15.txt"
echo "Update 15 reverted $TIMESTAMP" >> "$BASE/info-stand.txt"
