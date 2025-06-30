#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 04 (GUI-Updater)"
  echo "Würde löschen:"
  echo "creatoros/updater/update_manager.py"
  echo "creatoros/tests/test_update_manager.py"
  exit 0
fi

for file in creatoros/updater/update_manager.py creatoros/tests/test_update_manager.py; do
  if grep -q "# TODO" "$file"; then
    rm "$file"
    echo "$file gelöscht."
  else
    echo "$file wurde bereits angepasst; nicht gelöscht."
  fi
done

TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> meta/changes/change_04.txt
echo "Update 04 reverted $TIMESTAMP" >> info-stand.txt

echo "Re-Update 04 erfolgreich ausgeführt."
