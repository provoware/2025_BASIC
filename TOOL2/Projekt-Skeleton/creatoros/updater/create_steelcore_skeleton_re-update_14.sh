#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
MOD=creatoros/system/logger.py
TEST=creatoros/tests/test_logger.py
META=$BASE/meta/changes

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 14 (Logger)"
  exit 0
fi

rm -f "$BASE/$MOD" "$BASE/$TEST"
TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> "$META/change_14.txt"
echo "Update 14 reverted $TIMESTAMP" >> "$BASE/info-stand.txt"
