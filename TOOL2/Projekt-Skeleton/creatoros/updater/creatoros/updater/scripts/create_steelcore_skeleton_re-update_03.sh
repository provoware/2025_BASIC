#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 03 (Platzhalterprüfung)"
  echo "Würde löschen:"
  echo "creatoros/tools/validate_placeholders.py"
  echo "creatoros/tests/test_validate_placeholders.py"
  exit 0
fi

for file in creatoros/tools/validate_placeholders.py creatoros/tests/test_validate_placeholders.py; do
  if grep -q "# TODO" "$file"; then
    rm "$file"
    echo "$file gelöscht."
  else
    echo "$file wurde bereits angepasst; nicht gelöscht."
  fi
done

TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> meta/changes/change_03.txt
echo "Update 03 reverted $TIMESTAMP" >> info-stand.txt

echo "Re-Update 03 erfolgreich ausgeführt."
