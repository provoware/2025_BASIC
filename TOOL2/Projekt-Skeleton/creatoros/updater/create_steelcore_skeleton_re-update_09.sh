#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
TOOL_PATH=$BASE/creatoros/tools/validate_placeholders.py
TEST_PATH=$BASE/creatoros/tests/test_validate_placeholders.py
META_PATH=$BASE/meta/changes

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 09 (Platzhalterprüfung)"
  exit 0
fi

rm -f "$TOOL_PATH" "$TEST_PATH"
TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> "$META_PATH/change_09.txt"
echo "Update 09 reverted $TIMESTAMP" >> "$BASE/info-stand.txt"

echo "Re-Update 09 erfolgreich ausgeführt."
