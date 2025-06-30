#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
MOD=creatoros/modules/plugin_manager.py
TEST=creatoros/tests/test_plugin_manager.py
META=$BASE/meta/changes

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 13 (Plugin-Manager)"
  exit 0
fi

rm -f "$BASE/$MOD" "$BASE/$TEST"
TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> "$META/change_13.txt"
echo "Update 13 reverted $TIMESTAMP" >> "$BASE/info-stand.txt"
