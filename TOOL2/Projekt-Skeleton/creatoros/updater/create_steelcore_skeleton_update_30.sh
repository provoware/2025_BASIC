#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
META=$BASE/meta/changes
INFO=creatoros/updater/info-stand.txt
SUMS=creatoros/updater/CHECKSUMS.txt

echo "=== Update 30: QAction-Import-Fix ==="

# 1) Backup der bestehenden GUI
if [ -f "$GUI" ]; then
  cp "$GUI" "$BASE/conflicts/steelcore_dashboard.py.bak.$(date +%s)"
  echo "⚠️ Backup: $GUI → conflicts/"
fi

# 2) Korrigiere die Import-Zeilen
echo "▶️ Patching QAction-Import…"
sed -i '/from PyQt6.QtWidgets import (/,/)/c\
from PyQt6.QtWidgets import (\
    QApplication, QMainWindow, QWidget, QGridLayout, QDockWidget,\
    QToolBar, QComboBox, QMessageBox, QFileDialog, QPushButton,\
    QLabel, QStatusBar, QListWidget, QHBoxLayout, QVBoxLayout\
)\
from PyQt6.QtGui import QAction' "$GUI"

# 3) Validierung
echo "▶️ Syntax-Check…"
if python3 -m py_compile "$GUI"; then
  echo "   ✔ Keine Syntaxfehler."
else
  echo "❌ Syntax-Fehler nach Patch!"
  exit 1
fi

# 4) Metadaten & Checksum
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_30.txt"
ID: 30
Zeit: $STAMP
Beschreibung: Fix QAction Import aus QtGui statt QtWidgets
Dateien:
  - $GUI
EOF
echo "Update 30 applied $STAMP" >> "$INFO"
md5sum "$GUI" >> "$SUMS"

echo "✅ Update 30 erfolgreich abgeschlossen."
