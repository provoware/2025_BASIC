#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
META=$BASE/meta/changes
INFO=$BASE/info-stand.txt
SUMS=$BASE/CHECKSUMS.txt

NESTED="$BASE/creatoros/interface"
PROJECT_IF="creatoros/interface"

echo "=== Update 32: GUI-Dateien ins Projekt-Root verschieben ==="

# 1) Prüfen
if [ ! -d "$NESTED" ]; then
  echo "❌ Kein verschachtelter Interface-Ordner unter $NESTED gefunden. Abbruch."
  exit 1
fi

# 2) Ziel anlegen
mkdir -p "$PROJECT_IF"

# 3) Wichtige Dateien und Verzeichnisse verschieben
for ITEM in steelcore_dashboard.py settings.json theme_manager.py dashboard.log; do
  if [ -e "$NESTED/$ITEM" ]; then
    mv "$NESTED/$ITEM" "$PROJECT_IF/"
    echo "   ✔ $ITEM → $PROJECT_IF/"
  else
    echo "   ⚠️ $ITEM nicht in $NESTED gefunden, übersprungen."
  fi
done

# 4) Verzeichnisse verschieben
for DIR in themes profiles; do
  if [ -d "$NESTED/$DIR" ]; then
    mv "$NESTED/$DIR" "$PROJECT_IF/"
    echo "   ✔ Verzeichnis $DIR → $PROJECT_IF/"
  else
    echo "   ⚠️ Verzeichnis $DIR nicht in $NESTED gefunden, übersprungen."
  fi
done

# 5) Aufräumen der leeren verschachtelten Ordner
rmdir --ignore-fail-on-non-empty "$NESTED"                    && echo "   ✔ Entferne leeres $NESTED"
rmdir --ignore-fail-on-non-empty "$BASE/creatoros/interface"  && echo "   ✔ Entferne leeres $BASE/creatoros/interface"
rmdir --ignore-fail-on-non-empty "$BASE/creatoros"            && echo "   ✔ Entferne leeres $BASE/creatoros"

# 6) Metadaten & Checksum
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_32.txt"
ID: 32
Zeit: $STAMP
Beschreibung: Verschiebe Interface-Dateien ins Projekt-Root (creatoros/interface)
Dateien:
  - $PROJECT_IF/steelcore_dashboard.py
  - $PROJECT_IF/settings.json
  - $PROJECT_IF/theme_manager.py
  - $PROJECT_IF/dashboard.log
  - $PROJECT_IF/themes/
  - $PROJECT_IF/profiles/
EOF

echo "Update 32 applied $STAMP" >> "$INFO"
md5sum \
  "$PROJECT_IF/steelcore_dashboard.py" \
  "$PROJECT_IF/settings.json" >> "$SUMS" 

echo "✅ Update 32 erfolgreich abgeschlossen."
