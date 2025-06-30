#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 06 (Sandbox-Modul)"
  echo "Würde löschen:"
  echo "creatoros/plugins/sandbox.py"
  echo "creatoros/tests/test_sandbox.py"
  exit 0
fi

for file in creatoros/plugins/sandbox.py creatoros/tests/test_sandbox.py; do
  if grep -q "# TODO" "$file"; then
    rm "$file"
    echo "$file gelöscht."
  else
    echo "$file wurde bereits angepasst; nicht gelöscht."
  fi
done

TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> meta/changes/change_06.txt
echo "Update 06 reverted $TIMESTAMP" >> info-stand.txt

echo "Re-Update 06 erfolgreich ausgeführt."
