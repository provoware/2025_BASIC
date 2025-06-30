#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 01 (Debug & Auto-Repair-Modul)"
  echo "Würde löschen:"
  echo "creatoros/start_debug.py"
  echo "creatoros/modules/auto_repair.py"
  echo "creatoros/tests/test_auto_repair.py"
  exit 0
fi

# Nur Platzhalter mit __todo löschen (sicherstellen!)
for file in creatoros/start_debug.py creatoros/modules/auto_repair.py creatoros/tests/test_auto_repair.py; do
  if grep -q "# TODO" "$file"; then
    rm "$file"
    echo "$file gelöscht."
  else
    echo "$file wurde bereits angepasst; nicht gelöscht."
  fi
done

# Revert protokollieren
TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> meta/changes/change_01.txt
echo "Update 01 reverted $TIMESTAMP" >> info-stand.txt

echo "Re-Update 01 erfolgreich ausgeführt."
