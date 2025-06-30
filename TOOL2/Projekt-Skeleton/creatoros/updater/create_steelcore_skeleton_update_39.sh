#!/usr/bin/env bash
set -euo pipefail

# Update 39: A11y-, Theme-, Font-Scaling-, Shortcut- & Update-Manager-Erweiterung
BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
SETTINGS=creatoros/interface/settings.json
THEMES_DIR=creatoros/interface/themes
CONFLICTS=$BASE/conflicts
META=$BASE/meta/changes
INFO=$BASE/info-stand.txt
SUMS=$BASE/CHECKSUMS.txt

echo "=== Update 39: Profi-A11y, Themes, Font-Scaling, Shortcuts & Update-Panel ==="

# 1) Backups
mkdir -p "$CONFLICTS"
for F in "$GUI" "$SETTINGS"; do
  if [ -f "$F" ]; then
    cp "$F" "$CONFLICTS/$(basename "$F").bak.$(date +%s)"
    echo "⚠️ Backup: $F → conflicts/"
  fi
done

# 2) Add Contrast-Theme JSON
mkdir -p "$THEMES_DIR"
CONTRAST_JSON="$THEMES_DIR/default_contrast.json"
if [ ! -f "$CONTRAST_JSON" ]; then
  cat << 'EOF' > "$CONTRAST_JSON"
{
  "bg": "#000000",
  "fg": "#FFFFFF",
  "accent": "#FFD700",
  "accent-hover": "#FFC107",
  "panel-bg": "#1A1A1A",
  "panel-shadow": "rgba(255,255,255,0.1)"
}
EOF
  echo "✔ Contrast-Theme angelegt: $CONTRAST_JSON"
else
  echo "✔ Contrast-Theme existiert bereits."
fi

# 3) Ensure SETTINGS includes contrast, font_size, shortcut placeholders
if ! grep -q '"contrast"' "$SETTINGS"; then
  echo "▶️ Ergänze SETTINGS um Contrast-Theme und font_size"
  jq '. + {themes:["light","dark","contrast"]} | .settings.font_size? //=12' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  echo "   ✔ SETTINGS aktualisiert."
else
  echo "✔ SETTINGS enthält bereits die neuen Felder."
fi

# 4) Patch steelcore_dashboard.py
echo "▶️ Patch steelcore_dashboard.py"

patch "$GUI" << 'EOF'
*** Begin Patch
*** Update File: steelcore_dashboard.py
@@
-from PyQt6.QtWidgets import (
-    QApplication, QMainWindow, QWidget, QGridLayout, QDockWidget,
-    QToolBar, QComboBox, QMessageBox, QFileDialog, QLabel,
-    QStatusBar, QListWidget, QHBoxLayout, QVBoxLayout, QFrame
-)
+from PyQt6.QtWidgets import (
+    QApplication, QMainWindow, QWidget, QGridLayout, QDockWidget,
+    QToolBar, QComboBox, QMessageBox, QFileDialog, QLabel,
+    QStatusBar, QListWidget, QHBoxLayout, QVBoxLayout, QFrame,
+    QSlider, QShortcut
+)
 from PyQt6.QtGui import QAction
+from PyQt6.QtGui import QKeySequence, QFontDatabase
 from PyQt6.QtCore import Qt
*** End Patch
EOF

# Insert font-scaling, shortcuts, tooltips, and update-manager panel in __init__
awk '
  BEGIN {inInit=0}
  {
    print
    if ($0 ~ /def __init__\(self\)/) { inInit=1 }
    if (inInit && $0 ~ /# Settings & Theme/) {
      print "        # --- Accessibility: Font scaling slider ---"
      print "        slider = QSlider(Qt.Orientation.Horizontal)"
      print "        slider.setRange(8, 32)"
      print "        slider.setValue(self.settings.get(\"font_size\",12))"
      print "        slider.setToolTip(\"Schriftgröße ändern\")"
      print "        slider.setAccessibleName(\"Font-Size-Slider\")"
      print "        slider.valueChanged.connect(self.change_font_size)"
      print "        tb.addWidget(slider)"
      print ""
      print "        # --- Shortcuts ---"
      print "        QShortcut(QKeySequence(\"Ctrl+S\"), self, activated=self.current_ws.save).setContext(Qt.ApplicationShortcut)"
      print "        QShortcut(QKeySequence(\"Ctrl+N\"), self, activated=self.action_new_ws).setContext(Qt.ApplicationShortcut)"
      print "        QShortcut(QKeySequence(\"Ctrl+D\"), self, activated=self.toggle_theme).setContext(Qt.ApplicationShortcut)"
      print ""
      print "        # --- Tooltips & Accessible Names for actions ---"
      print "        for act, name, tip in [(tb.actions()[0],\"Workspace-Combo\",\"Workspace wählen\"),"
      print "                              (tb.actions()[1],\"Neu-Workspace\",\"Neuen Workspace anlegen\"),"
      print "                              (tb.actions()[3],\"Duplizieren-Workspace\",\"Workspace duplizieren\"),"
      print "                              (tb.actions()[5],\"Löschen-Workspace\",\"Workspace löschen\"),"
      print "                              (tb.actions()[-2],\"Theme-Toggle\",\"Theme umschalten\"),"
      print "                              (tb.actions()[-1],\"Save-Workspace\",\"Workspace speichern\")]:" 
      print "            act.setToolTip(tip); act.setAccessibleName(name)"
      print ""
      print "        # --- Update-Manager Panel ---"
      print "        upd_dock = QDockWidget(\"Updates\", self)"
      print "        upd_list = QListWidget()"
      print "        for f in sorted(os.listdir(os.path.join(os.path.dirname(__file__),\"../updater\"))):"
      print "            if f.startswith(\"create_steelcore_skeleton_update\"):"
      print "                upd_list.addItem(f)"
      print "        upd_dock.setWidget(upd_list)"
      print "        self.addDockWidget(Qt.DockWidgetArea.LeftDockWidgetArea, upd_dock)"
    }
    if (inInit && $0 ~ /# Load panels/) {
      inInit=0
    }
  }
' "$GUI" > "$GUI.patched" && mv "$GUI.patched" "$GUI"

# 5) Add change_font_size method and apply_font in MainWindow
awk '
  BEGIN {inserted=0}
  {
    print
    if (!$0 ~ /def toggle_theme/) next
    if ($0 ~ /def toggle_theme/) {
      print; print "    def change_font_size(self, size):"
      print "        # Font-Größe anpassen"
      print "        self.settings[\"font_size\"] = size"
      print "        font = QFontDatabase.systemFont(QFontDatabase.SystemFont.TitleFont)"
      print "        font.setPointSize(size)"
      print "        QApplication.instance().setFont(font)"
      print "        self.save_settings()"
      print ""
    }
  }
' "$GUI" > "$GUI.patched" && mv "$GUI.patched" "$GUI"

# 6) Syntax check
echo "▶️ Syntax-Validierung…"
if python3 -m py_compile "$GUI"; then
  echo "   ✔ Keine Syntaxfehler."
else
  echo "❌ Syntax-Fehler nach Update 39!"
  exit 1
fi

# 7) Meta & checksum
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_39.txt"
ID: 39
Zeit: $STAMP
Beschreibung: A11y-Fonts-Slider, Shortcuts, Tooltips, Contrast-Theme & Update-Manager-Panel
Dateien:
  - $GUI
  - $SETTINGS
  - $CONTRAST_JSON
EOF
echo "Update 39 applied $STAMP" >> "$INFO"
md5sum "$GUI" "$SETTINGS" "$CONTRAST_JSON" >> "$SUMS"

echo "✅ Update 39 abgeschlossen. Bitte Projekt-Root: bash start_gui_dashboard.sh"
