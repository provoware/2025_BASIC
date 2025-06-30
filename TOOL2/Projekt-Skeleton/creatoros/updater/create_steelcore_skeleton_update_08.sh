#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}
BASE=creatoros/updater

MODULE_PATH=$BASE/creatoros/modules/auto_repair.py
TEST_PATH=$BASE/creatoros/tests/test_auto_repair.py
META_PATH=$BASE/meta/changes
CONFLICT_PATH=$BASE/conflicts

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 08 (Auto-Repair real)"
  echo "Würde schreiben:"
  echo "$MODULE_PATH"
  echo "$TEST_PATH"
  exit 0
fi

# Struktur absichern
mkdir -p $(dirname "$MODULE_PATH")
mkdir -p $(dirname "$TEST_PATH")
mkdir -p "$META_PATH"
mkdir -p "$CONFLICT_PATH"

# Sicherung bei Vorhandensein
for f in "$MODULE_PATH" "$TEST_PATH"; do
  if [ -f "$f" ]; then
    mv "$f" "$CONFLICT_PATH/$(basename "$f").bak.$(date +%s)"
    echo "[WARNUNG] Bestehende Datei verschoben nach: $CONFLICT_PATH"
  fi
done

# Neue Inhalte schreiben
cat <<EOF > "$MODULE_PATH"
# -*- coding: utf-8 -*-
import os

REQUIRED_DIRS = [
    "creatoros/boot",
    "creatoros/system",
    "creatoros/interface",
    "creatoros/modules",
    "creatoros/db",
    "creatoros/logs",
    "creatoros/plugins"
]

def repair_structure(base_path="."):
    results = []
    for d in REQUIRED_DIRS:
        full_path = os.path.join(base_path, d)
        if not os.path.exists(full_path):
            os.makedirs(full_path, exist_ok=True)
            results.append(f"{d} angelegt")
        else:
            results.append(f"{d} vorhanden")
    return results
EOF

cat <<EOF > "$TEST_PATH"
# -*- coding: utf-8 -*-
import shutil
import os
import tempfile
from creatoros.modules import auto_repair

def test_repair_structure_creates_missing_dirs():
    with tempfile.TemporaryDirectory() as tmp:
        base = os.path.join(tmp, "creatoros")
        os.makedirs(os.path.join(base, "system"))  # einer existiert
        result = auto_repair.repair_structure(base_path=tmp)
        required = [f"creatoros/{d}" for d in ["boot", "interface", "modules", "db", "logs", "plugins", "system"]]
        for r in required:
            assert os.path.isdir(os.path.join(tmp, r)), f"{r} fehlt"
        assert "creatoros/system vorhanden" in result
        assert "creatoros/boot angelegt" in result
EOF

chmod +x "$MODULE_PATH"

# Protokollierung
TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 08\nZeit: $TIMESTAMP\nBeschreibung: Auto-Repair mit Strukturprüfung implementiert\nDateien:\n  - $MODULE_PATH\n  - $TEST_PATH" > "$META_PATH/change_08.txt"
echo "Update 08 applied $TIMESTAMP" >> "$BASE/info-stand.txt"

# MD5
md5sum "$MODULE_PATH" "$TEST_PATH" >> "$BASE/CHECKSUMS.txt"

echo "Update 08 erfolgreich angewendet."
