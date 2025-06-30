#!/usr/bin/env bash
set -euo pipefail
rm -f creatoros/interface/.grid_state.json creatoros/interface/dashboard.log
STAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $STAMP" >> creatoros/updater/meta/changes/change_23.txt
echo "Update 23 reverted $STAMP" >> creatoros/updater/info-stand.txt
