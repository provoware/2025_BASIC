#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 02 (Strukturprüfung)"
  echo "Würde löschen:"
  echo "creatoros/system/check_structure.py"
  echo "creatoros/tests/test_check_structure.py"
  exit 0
fi

for file in creatoros/system/check_structure.py creatoros/tests/test_check_structure.py; do
  if grep -q "# TODO" "$file"; then
    rm "$file"
    echo "$file gelöscht."
  else
    echo "$file wurde bereits angepasst; nicht gelöscht."
  fi
done

TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> meta/changes/change_02.txt
echo "Update 02 reverted $TIMESTAMP" >> info-stand.txt

echo "Re-Update 02 erfolgreich ausgeführt."
