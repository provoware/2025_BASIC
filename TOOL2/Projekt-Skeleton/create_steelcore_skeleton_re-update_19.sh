#!/usr/bin/env bash
set -euo pipefail

STAMP=$(date --iso-8601=seconds)
echo "[REVERTED] $STAMP" >> creatoros/updater/meta/changes/change_19.txt
echo "Update 19 reverted $STAMP" >> creatoros/updater/info-stand.txt
