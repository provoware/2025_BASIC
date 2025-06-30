#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
MOD=creatoros/modules/database.py
TEST=creatoros/tests/test_database.py
META=$BASE/meta/changes

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 11 (SQLite)"
  exit 0
fi

rm -f "$BASE/$MOD" "$BASE/$TEST"
TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> "$META/change_11.txt"
echo "Update 11 reverted $TIMESTAMP" >> "$BASE/info-stand.txt"
