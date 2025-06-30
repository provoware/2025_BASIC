#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 04 (GUI-Updater)"
  echo "Würde erstellen:"
  echo "creatoros/updater/update_manager.py"
  echo "creatoros/tests/test_update_manager.py"
  exit 0
fi

# Ordnerstruktur sicherstellen
mkdir -p creatoros/updater
mkdir -p creatoros/tests
mkdir -p meta/changes

# Platzhalter-Dateien erstellen
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/updater/update_manager.py
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/tests/test_update_manager.py

# Platzhalter ersetzen
rm -f creatoros/updater/update_manager__todo.py

# Berechtigungen setzen
chmod +x creatoros/updater/update_manager.py creatoros/tests/test_update_manager.py

# Protokollierung
TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 04\nZeit: $TIMESTAMP\nBeschreibung: GUI-Updater (Stub) erzeugt\nDateien:\n  - creatoros/updater/update_manager.py\n  - creatoros/tests/test_update_manager.py" > meta/changes/change_04.txt
echo "Update 04 applied $TIMESTAMP" >> info-stand.txt

# MD5-Checksummen
md5sum creatoros/updater/update_manager.py creatoros/tests/test_update_manager.py >> CHECKSUMS.txt

echo "Update 04 erfolgreich angewendet."
