#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
META=$BASE/meta/changes
INFO=$BASE/info-stand.txt
SUMS=$BASE/CHECKSUMS.txt

echo "=== Update 34: QFrame-Import & setFrameShape-Fix ==="

# 1) Backup der aktuellen GUI
mkdir -p "$BASE/conflicts"
cp "$GUI" "$BASE/conflicts/steelcore_dashboard.py.bak.$(date +%s)"
echo "⚠️ Backup: $GUI → conflicts/"

# 2) QtWidgets-Import um QFrame ergänzen
echo "▶️ QtWidgets-Import patchen..."
sed -i "/from PyQt6.QtWidgets import (/,/\)/c\
from PyQt6.QtWidgets import (\
    QApplication, QMainWindow, QWidget, QGridLayout, QDockWidget,\
    QToolBar, QComboBox, QMessageBox, QFileDialog, QLabel,\
    QStatusBar, QListWidget, QHBoxLayout, QVBoxLayout, QFrame\
)" "$GUI"

# 3) Fehlerhafte setFrameShape-Zuweisung entfernen
echo "▶️ Ungültige setFrameShape-Zuweisung löschen..."
sed -i "/self.setFrameShape = QFrame.StyledPanel/d" "$GUI"

# 4) Syntax-Check
echo "▶️ Syntax-Validierung..."
if python3 -m py_compile "$GUI"; then
  echo "   ✔ Keine Syntaxfehler."
else
  echo "❌ Syntax-Fehler nach Patch!"
  exit 1
fi

# 5) Metadaten & Checksum
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_34.txt"
ID: 34
Zeit: $STAMP
Beschreibung: Import von QFrame ergänzt & ungültige setFrameShape-Zeile entfernt
Dateien:
  - $GUI
EOF

echo "Update 34 applied $STAMP" >> "$INFO"
md5sum "$GUI" >> "$SUMS"

echo "✅ Update 34 erfolgreich abgeschlossen."
