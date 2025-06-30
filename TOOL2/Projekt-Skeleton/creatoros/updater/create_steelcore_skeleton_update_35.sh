#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
META=$BASE/meta/changes
INFO=$BASE/info-stand.txt
SUMS=$BASE/CHECKSUMS.txt

echo "=== Update 35: Autorepair für QFrame & setFrameShape ==="

# 1) Backup
mkdir -p "$BASE/conflicts"
cp "$GUI" "$BASE/conflicts/steelcore_dashboard.py.bak.$(date +%s)"
echo "⚠️ Backup: $GUI → conflicts/"

# 2) Import QFrame sicherstellen (nur einmal)
if grep -q 'QFrame' "$GUI"; then
  echo "✔ QFrame-Import bereits vorhanden."
else
  echo "▶️ Füge QFrame-Import hinzu..."
  sed -i '/from PyQt6\.QtWidgets import (/,/\)/ s/\()\s*$/\, QFrame)/' "$GUI"
  echo "   ✔ QFrame importiert."
fi

# 3) Entferne fehlerhafte self.setFrameShape-Zeilen
echo "▶️ Entferne ungültige setFrameShape-Zuweisungen..."
sed -i '/self\.setFrameShape/d' "$GUI"
echo "   ✔ Ungültige Zuweisungen entfernt."

# 4) Wrappe frame.setFrameShape-Aufrufe mit try/except für Selbstheilung
echo "▶️ Wrappe frame.setFrameShape mit try/except..."
sed -i '/frame\.setFrameShape/ s|^.*$|try:\n    frame.setFrameShape(QFrame.Shape.StyledPanel)\nexcept AttributeError:\n    pass|' "$GUI"
echo "   ✔ Autorepair-Block eingefügt."

# 5) Syntax-Validierung
echo "▶️ Syntax-Validierung…"
if python3 -m py_compile "$GUI"; then
  echo "   ✔ Keine Syntaxfehler."
else
  echo "❌ Syntax-Fehler nach Autorepair!"
  exit 1
fi

# 6) Metadaten & Checksum
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_35.txt"
ID: 35
Zeit: $STAMP
Beschreibung: Autorepair für QFrame-Import & setFrameShape mit try/except
Dateien:
  - $GUI
EOF

echo "Update 35 applied $STAMP" >> "$INFO"
md5sum "$GUI" >> "$SUMS"

echo "✅ Update 35 erfolgreich abgeschlossen."
