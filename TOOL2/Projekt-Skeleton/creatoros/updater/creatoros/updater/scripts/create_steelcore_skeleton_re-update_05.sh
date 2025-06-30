#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 05 (Datenbankmodul)"
  echo "Würde löschen:"
  echo "creatoros/db/database.py"
  echo "creatoros/tests/test_database.py"
  exit 0
fi

for file in creatoros/db/database.py creatoros/tests/test_database.py; do
  if grep -q "# TODO" "$file"; then
    rm "$file"
    echo "$file gelöscht."
  else
    echo "$file wurde bereits angepasst; nicht gelöscht."
  fi
done

TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> meta/changes/change_05.txt
echo "Update 05 reverted $TIMESTAMP" >> info-stand.txt

echo "Re-Update 05 erfolgreich ausgeführt."
