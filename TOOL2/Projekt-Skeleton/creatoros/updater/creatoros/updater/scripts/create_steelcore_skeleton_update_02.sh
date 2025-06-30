#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 02 (Strukturprüfung)"
  echo "Würde erstellen:"
  echo "creatoros/system/check_structure.py"
  echo "creatoros/tests/test_check_structure.py"
  exit 0
fi

# Ordnerstruktur sicherstellen
mkdir -p creatoros/system
mkdir -p creatoros/tests
mkdir -p meta/changes

# Platzhalter-Dateien erstellen
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/system/check_structure.py
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/tests/test_check_structure.py

# Berechtigungen setzen
chmod +x creatoros/system/check_structure.py creatoros/tests/test_check_structure.py

# Protokollierung
TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 02\nZeit: $TIMESTAMP\nBeschreibung: Strukturprüfung & Autorepair-Modul\nDateien:\n  - creatoros/system/check_structure.py\n  - creatoros/tests/test_check_structure.py" > meta/changes/change_02.txt
echo "Update 02 applied $TIMESTAMP" >> info-stand.txt

# MD5-Checksummen
md5sum creatoros/system/check_structure.py creatoros/tests/test_check_structure.py >> CHECKSUMS.txt

echo "Update 02 erfolgreich angewendet."
