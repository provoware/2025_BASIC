#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 05 (Datenbankmodul)"
  echo "Würde erstellen:"
  echo "creatoros/db/database.py"
  echo "creatoros/tests/test_database.py"
  exit 0
fi

# Ordnerstruktur sicherstellen
mkdir -p creatoros/db
mkdir -p creatoros/tests
mkdir -p meta/changes

# Platzhalter-Dateien erstellen
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/db/database.py
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/tests/test_database.py

# Berechtigungen setzen
chmod +x creatoros/db/database.py creatoros/tests/test_database.py

# Protokollierung
TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 05\nZeit: $TIMESTAMP\nBeschreibung: SQLite-Datenbankmodul vorbereitet\nDateien:\n  - creatoros/db/database.py\n  - creatoros/tests/test_database.py" > meta/changes/change_05.txt
echo "Update 05 applied $TIMESTAMP" >> info-stand.txt

# MD5-Checksummen
md5sum creatoros/db/database.py creatoros/tests/test_database.py >> CHECKSUMS.txt

echo "Update 05 erfolgreich angewendet."
