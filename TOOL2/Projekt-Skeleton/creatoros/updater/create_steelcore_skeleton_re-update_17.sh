#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
GUI=creatoros/interface/status_dashboard.py
DASH=start_dashboard.sh
META=$BASE/meta/changes
UPDATER=creatoros/updater/creatoros/updater/update_manager.py

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Entferne Update 17 (Dashboard)"
  exit 0
fi

rm -f "$GUI" "$DASH"
sed -i '/📊 Status/,/open_dashboard/d' "$UPDATER"

TIMESTAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $TIMESTAMP" >> "$META/change_17.txt"
echo "Update 17 reverted $TIMESTAMP" >> "$BASE/info-stand.txt"
