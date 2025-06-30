#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 01 (Debug & Auto-Repair-Modul)"
  echo "Würde erstellen:"
  echo "creatoros/start_debug.py"
  echo "creatoros/modules/auto_repair.py"
  echo "creatoros/tests/test_auto_repair.py"
  exit 0
fi

# Ordnerstruktur sicherstellen
mkdir -p creatoros/modules
mkdir -p creatoros/tests

# Platzhalter-Dateien erstellen
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/start_debug.py
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/modules/auto_repair.py
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/tests/test_auto_repair.py

# Berechtigungen setzen
chmod +x creatoros/start_debug.py creatoros/modules/auto_repair.py creatoros/tests/test_auto_repair.py

# Protokollierung
TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 01\nZeit: $TIMESTAMP\nBeschreibung: Debug-Modus & Auto-Repair initialisiert\nDateien:\n  - creatoros/start_debug.py\n  - creatoros/modules/auto_repair.py\n  - creatoros/tests/test_auto_repair.py" > meta/changes/change_01.txt
echo "Update 01 applied $TIMESTAMP" >> info-stand.txt

# MD5-Checksummen
md5sum creatoros/start_debug.py creatoros/modules/auto_repair.py creatoros/tests/test_auto_repair.py >> CHECKSUMS.txt

echo "Update 01 erfolgreich angewendet."
