#!/usr/bin/env bash
set -euo pipefail
rm -f creatoros/interface/steelcore_dashboard.py start_gui_dashboard.sh
STAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $STAMP" >> creatoros/updater/meta/changes/change_20.txt
echo "Update 20 reverted $STAMP" >> creatoros/updater/info-stand.txt
