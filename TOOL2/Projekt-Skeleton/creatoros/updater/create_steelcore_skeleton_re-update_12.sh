#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
MOD=creatoros/interface/theme_manager.py
TEST=creatoros/tests/test_theme_manager.py
META=$BASE/meta/changes

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 12 (Theme-Manager)"
  exit 0
fi

rm -f "$BASE/$MOD" "$BASE/$TEST"
TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> "$META/change_12.txt"
echo "Update 12 reverted $TIMESTAMP" >> "$BASE/info-stand.txt"
