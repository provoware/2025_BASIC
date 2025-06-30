#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
META=$BASE/meta/changes
INFO=$BASE/info-stand.txt
SUMS=$BASE/CHECKSUMS.txt

if [[ "${1:-}" == "--dry-run" ]]; then
  echo "[DRY RUN] Update 42: QAction-Import-Fix für PySide6"
  echo " → Backup steelcore_dashboard.py"
  echo " → Entferne QAction aus QtWidgets-Import"
  echo " → Ergänze QAction im QtGui-Import"
  echo " → Syntax-Check steelcore_dashboard.py"
  exit 0
fi

echo "=== Update 42: QAction-Import-Fix für PySide6 ==="

# 1) Backup
mkdir -p "$BASE/conflicts"
cp "$GUI" "$BASE/conflicts/steelcore_dashboard.py.bak.$(date +%s)"
echo "⚠️ Backup: $GUI → conflicts/"

# 2) Entferne QAction aus QtWidgets-Import
echo "▶️ Entferne QAction aus PySide6.QtWidgets-Import…"
sed -i "/from PySide6\.QtWidgets import/,/)/ s/, *QAction//" "$GUI"
echo "   ✔ QAction aus QtWidgets-Import entfernt."

# 3) Ergänze QAction im QtGui-Import
echo "▶️ Ergänze QAction im PySide6.QtGui-Import…"
if grep -q "from PySide6.QtGui import" "$GUI"; then
  sed -i "/from PySide6\.QtGui import/ s/$/, QAction/" "$GUI"
else
  sed -i "/from PySide6\.QtWidgets import/a from PySide6.QtGui import QAction" "$GUI"
fi
echo "   ✔ QAction im QtGui-Import hinzugefügt."

# 4) Syntax-Validierung
echo "▶️ Syntax-Validierung…"
if python3 -m py_compile "$GUI"; then
  echo "   ✔ Keine Syntaxfehler."
else
  echo "❌ Syntax-Fehler! Bitte manuell prüfen."
  exit 1
fi

# 5) Metadaten & Checksum
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_42.txt"
ID: 42
Zeit: $STAMP
Beschreibung: QAction-Import für PySide6 korrigiert (aus QtWidgets entfernt, zu QtGui verschoben)
Dateien:
  - $GUI
EOF

echo "Update 42 applied $STAMP" >> "$INFO"
md5sum "$GUI" >> "$SUMS"

echo "✅ Update 42 erfolgreich abgeschlossen. Jetzt neu starten mit: bash start_gui_dashboard.sh"
