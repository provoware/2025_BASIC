#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
MOD=creatoros/system/cleanup_manager.py
TEST=creatoros/tests/test_cleanup_manager.py
START=start_cleanup.sh
META=$BASE/meta/changes

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 16 (Cleanup)"
  exit 0
fi

rm -f "$BASE/$MOD" "$BASE/$TEST" "$START"
TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> "$META/change_16.txt"
echo "Update 16 reverted $TIMESTAMP" >> "$BASE/info-stand.txt"
