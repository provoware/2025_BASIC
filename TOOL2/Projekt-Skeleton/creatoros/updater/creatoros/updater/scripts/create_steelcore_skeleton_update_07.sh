#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=${1:-}

if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 07 (Themes & Barrierefreiheit)"
  echo "Würde erstellen:"
  echo "creatoros/interface/theme_manager.py"
  echo "creatoros/interface/themes/default_light.json"
  echo "creatoros/interface/themes/default_dark.json"
  echo "creatoros/tests/test_theme_manager.py"
  exit 0
fi

# Ordnerstruktur sicherstellen
mkdir -p creatoros/interface/themes
mkdir -p creatoros/tests
mkdir -p meta/changes

# Dateien erstellen
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/interface/theme_manager.py
echo "# -*- coding: utf-8 -*-\n# TODO" > creatoros/tests/test_theme_manager.py
echo '{\n  "bg_color": "#FFFFFF",\n  "font_size": 14,\n  "high_contrast": false\n}' > creatoros/interface/themes/default_light.json
echo '{\n  "bg_color": "#000000",\n  "font_size": 16,\n  "high_contrast": true\n}' > creatoros/interface/themes/default_dark.json

# Berechtigungen setzen
chmod +x creatoros/interface/theme_manager.py creatoros/tests/test_theme_manager.py

# Protokollierung
TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 07\nZeit: $TIMESTAMP\nBeschreibung: Theme- & Barrierefreiheits-Stub\nDateien:\n  - creatoros/interface/theme_manager.py\n  - creatoros/interface/themes/default_light.json\n  - creatoros/interface/themes/default_dark.json\n  - creatoros/tests/test_theme_manager.py" > meta/changes/change_07.txt
echo "Update 07 applied $TIMESTAMP" >> info-stand.txt

# MD5-Checksummen
md5sum creatoros/interface/theme_manager.py creatoros/interface/themes/default_light.json creatoros/interface/themes/default_dark.json creatoros/tests/test_theme_manager.py >> CHECKSUMS.txt

echo "Update 07 erfolgreich angewendet."
