#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 06 (Sandbox-Modul)"
  echo "Würde erstellen:"
  echo "creatoros/plugins/sandbox.py"
  echo "creatoros/tests/test_sandbox.py"
  exit 0
fi

# Ordnerstruktur sicherstellen
mkdir -p creatoros/plugins
mkdir -p creatoros/tests
mkdir -p meta/changes

# Platzhalter-Dateien erstellen
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/plugins/sandbox.py
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/tests/test_sandbox.py

# Berechtigungen setzen
chmod +x creatoros/plugins/sandbox.py creatoros/tests/test_sandbox.py

# Protokollierung
TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 06\nZeit: $TIMESTAMP\nBeschreibung: Sicherheits-Sandbox vorbereitet\nDateien:\n  - creatoros/plugins/sandbox.py\n  - creatoros/tests/test_sandbox.py" > meta/changes/change_06.txt
echo "Update 06 applied $TIMESTAMP" >> info-stand.txt

# MD5-Checksummen
md5sum creatoros/plugins/sandbox.py creatoros/tests/test_sandbox.py >> CHECKSUMS.txt

echo "Update 06 erfolgreich angewendet."
