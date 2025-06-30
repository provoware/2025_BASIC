#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 03 (Platzhalterprüfung)"
  echo "Würde erstellen:"
  echo "creatoros/tools/validate_placeholders.py"
  echo "creatoros/tests/test_validate_placeholders.py"
  exit 0
fi

# Ordnerstruktur sicherstellen
mkdir -p creatoros/tools
mkdir -p creatoros/tests
mkdir -p meta/changes

# Platzhalter-Dateien erstellen
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/tools/validate_placeholders.py
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/tests/test_validate_placeholders.py

# Berechtigungen setzen
chmod +x creatoros/tools/validate_placeholders.py creatoros/tests/test_validate_placeholders.py

# Protokollierung
TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 03\nZeit: $TIMESTAMP\nBeschreibung: Platzhalter-Validator angelegt\nDateien:\n  - creatoros/tools/validate_placeholders.py\n  - creatoros/tests/test_validate_placeholders.py" > meta/changes/change_03.txt
echo "Update 03 applied $TIMESTAMP" >> info-stand.txt

# MD5-Checksummen
md5sum creatoros/tools/validate_placeholders.py creatoros/tests/test_validate_placeholders.py >> CHECKSUMS.txt

echo "Update 03 erfolgreich angewendet."
