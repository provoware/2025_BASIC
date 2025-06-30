#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
TARGET=$BASE/creatoros/updater/update_manager.py
TEST=$BASE/creatoros/tests/test_update_manager.py
META=$BASE/meta/changes

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 10 (GUI-Updater)"
  exit 0
fi

rm -f "$TARGET" "$TEST"
TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> "$META/change_10.txt"
echo "Update 10 reverted $TIMESTAMP" >> "$BASE/info-stand.txt"
