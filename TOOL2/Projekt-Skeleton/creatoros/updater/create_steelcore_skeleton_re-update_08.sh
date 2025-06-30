#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}
BASE=creatoros/updater

MODULE_PATH=$BASE/creatoros/modules/auto_repair.py
TEST_PATH=$BASE/creatoros/tests/test_auto_repair.py
META_PATH=$BASE/meta/changes

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 08 (Auto-Repair)"
  echo "Würde löschen:"
  echo "$MODULE_PATH"
  echo "$TEST_PATH"
  exit 0
fi

for file in "$MODULE_PATH" "$TEST_PATH"; do
  if grep -q "# -*- coding: utf-8 -*-" "$file"; then
    rm "$file"
    echo "$file gelöscht."
  else
    echo "$file wurde verändert – nicht gelöscht."
  fi
done

TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> "$META_PATH/change_08.txt"
echo "Update 08 reverted $TIMESTAMP" >> "$BASE/info-stand.txt"

echo "Re-Update 08 erfolgreich ausgeführt."
