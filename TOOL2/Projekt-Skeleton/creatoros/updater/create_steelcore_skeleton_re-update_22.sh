#!/usr/bin/env bash
set -euo pipefail
rm -f creatoros/interface/.grid_state.json
STAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $STAMP" >> creatoros/updater/meta/changes/change_22.txt
echo "Update 22 reverted $STAMP" >> creatoros/updater/info-stand.txt
