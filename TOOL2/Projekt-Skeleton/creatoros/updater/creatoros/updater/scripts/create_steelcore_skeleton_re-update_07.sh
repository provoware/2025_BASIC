#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 07 (Themes & Barrierefreiheit)"
  echo "Würde löschen:"
  echo "creatoros/interface/theme_manager.py"
  echo "creatoros/interface/themes/default_light.json"
  echo "creatoros/interface/themes/default_dark.json"
  echo "creatoros/tests/test_theme_manager.py"
  exit 0
fi

for file in creatoros/interface/theme_manager.py creatoros/interface/themes/default_light.json creatoros/interface/themes/default_dark.json creatoros/tests/test_theme_manager.py; do
  if grep -q "# TODO" "$file" || grep -q "bg_color" "$file"; then
    rm "$file"
    echo "$file gelöscht."
  else
    echo "$file wurde bereits angepasst; nicht gelöscht."
  fi
done

TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> meta/changes/change_07.txt
echo "Update 07 reverted $TIMESTAMP" >> info-stand.txt

echo "Re-Update 07 erfolgreich ausgeführt."
