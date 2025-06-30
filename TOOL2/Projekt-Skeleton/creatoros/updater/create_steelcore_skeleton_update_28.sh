#!/usr/bin/env bash
set -euo pipefail

# Update 28: Profi-GUI mit Workspaces, Panel-Manager & modernen Elementen für Laien
BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
SETTINGS=creatoros/interface/settings.json
PROFILES_DIR=creatoros/interface/profiles
META=$BASE/meta/changes
CONFLICT=$BASE/conflicts

DRY_RUN=${1:-}
if [ "$DRY_RUN" = "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 28: Profi-GUI mit Workspaces & Panel-Manager"
  echo " → $GUI"
  echo " → $SETTINGS"
  echo " → Profile in $PROFILES_DIR"
  exit 0
fi

# Ordner sicherstellen
mkdir -p "$(dirname "$GUI")" "$(dirname "$SETTINGS")" "$PROFILES_DIR" "$META" "$CONFLICT"

# Backup alte Versionen
for F in "$GUI" "$SETTINGS"; do
  if [ -f "$F" ]; then
    mv "$F" "$CONFLICT/$(basename "$F").bak.$(date +%s)"
    echo "[WARNUNG] $F gesichert"
  fi
done

# Profi-GUI: PyQt6-basiert, Workspaces & Panel-Manager
cat << 'EOF' > "$GUI"
# -*- coding: utf-8 -*-
import sys, os, json, datetime
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QGridLayout, QDockWidget,
    QAction, QToolBar, QComboBox, QMessageBox, QFileDialog, QPushButton,
    QLabel, QStatusBar, QListWidget, QHBoxLayout, QVBoxLayout
)
from PyQt6.QtCore import Qt

def resource_path(rel):
    return os.path.join(os.path.dirname(__file__), rel)

# Pfade
SETTINGS_FILE = resource_path("settings.json")
PROFILES_DIR = resource_path("profiles")

# Default-Einstellungen
DEFAULT_SETTINGS = {
    "theme": "light",
    "font_size": 12,
    "grid": {"rows":3, "cols":4},
}

class Workspace:
    def __init__(self, name):
        self.name = name
        self.file = os.path.join(PROFILES_DIR, f"{name}.json")
        if os.path.exists(self.file):
            self.data = json.load(open(self.file, encoding="utf-8"))
        else:
            self.data = {
                "name": name,
                "panels": [],      # Liste von Panel-Configs
                "log": [],         # Aktion-Log
                "last_saved": None
            }
        self.log(f"Workspace '{self.name}' geladen")

    def save(self):
        self.data["last_saved"] = datetime.datetime.now().isoformat()
        json.dump(self.data, open(self.file, "w", encoding="utf-8"), indent=2)
        self.log("Workspace gespeichert")

    def log(self, msg):
        ts = datetime.datetime.now().strftime("%H:%M:%S")
        entry = f"[{ts}] {msg}"
        self.data["log"].insert(0, entry)
        if len(self.data["log"])>100: self.data["log"].pop()
        return entry

class PanelWidget(QDockWidget):
    def __init__(self, cfg, parent):
        super().__init__(cfg.get("title","Panel"), parent)
        self.cfg = cfg
        w = QWidget()
        layout = QVBoxLayout()
        layout.addWidget(QLabel(f"<b>Typ:</b> {cfg.get('type','–')}"))
        layout.addWidget(QLabel(f"<b>Einstellungen:</b> {cfg.get('config','–')}"))
        w.setLayout(layout)
        self.setWidget(w)

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        # UI-Grundlagen
        self.setWindowTitle("Steel-Core Profi-Dashboard")
        self.resize(1280, 900)
        self.status = QStatusBar()
        self.setStatusBar(self.status)

        # Load global settings
        self.settings = self.load_settings()
        self.apply_theme()

        # Load workspaces
        self.workspaces = []
        for f in os.listdir(PROFILES_DIR):
            if f.endswith(".json"):
                self.workspaces.append(f[:-5])
        if not self.workspaces:
            self.new_workspace("Default")
        self.current_ws = Workspace(self.workspaces[0])

        # Toolbar: Profile & Aktionen
        tb = QToolBar("Haupt")
        self.addToolBar(tb)
        self.cb_ws = QComboBox()
        self.cb_ws.addItems(self.workspaces)
        self.cb_ws.currentTextChanged.connect(self.switch_workspace)
        tb.addWidget(self.cb_ws)
        tb.addAction(QAction("Neu", self, triggered=self.action_new_ws))
        tb.addAction(QAction("Duplizieren", self, triggered=self.action_dup_ws))
        tb.addAction(QAction("Löschen", self, triggered=self.action_del_ws))
        tb.addSeparator()
        tb.addAction(QAction("Theme", self, triggered=self.toggle_theme))
        tb.addAction(QAction("Speichern", self, triggered=self.current_ws.save))

        # Central Grid für Panels
        central = QWidget()
        self.grid = QGridLayout()
        central.setLayout(self.grid)
        self.setCentralWidget(central)
        self.load_panels()

        # Dock für Log
        dock_log = QDockWidget("Logverlauf", self)
        self.log_list = QListWidget()
        dock_log.setWidget(self.log_list)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, dock_log)
        self.refresh_log()

    def load_settings(self):
        if os.path.exists(SETTINGS_FILE):
            return json.load(open(SETTINGS_FILE, encoding="utf-8"))
        else:
            return DEFAULT_SETTINGS.copy()

    def save_settings(self):
        json.dump(self.settings, open(SETTINGS_FILE, "w", encoding="utf-8"), indent=2)

    def apply_theme(self):
        th = self.settings.get("theme","light")
        pal = self.palette()
        if th=="dark":
            pal.setColor(self.backgroundRole(), Qt.GlobalColor.black)
            pal.setColor(self.foregroundRole(), Qt.GlobalColor.white)
        else:
            pal.setColor(self.backgroundRole(), Qt.GlobalColor.white)
            pal.setColor(self.foregroundRole(), Qt.GlobalColor.black)
        self.setPalette(pal)

    def switch_workspace(self, name):
        self.current_ws = Workspace(name)
        self.refresh_grid()
        self.refresh_log()

    def action_new_ws(self):
        name, ok = QFileDialog.getSaveFileName(self, "Neuer Workspace", PROFILES_DIR, "JSON (*.json)")
        if ok and name:
            base = os.path.splitext(os.path.basename(name))[0]
            self.current_ws = Workspace(base)
            self.workspaces.append(base)
            self.cb_ws.addItem(base)
            self.cb_ws.setCurrentText(base)

    def action_dup_ws(self):
        base = self.current_ws.name + "_copy"
        self.current_ws.data["name"] = base
        self.current_ws.file = os.path.join(PROFILES_DIR, f"{base}.json")
        self.current_ws.save()
        self.workspaces.append(base)
        self.cb_ws.addItem(base)
        self.cb_ws.setCurrentText(base)

    def action_del_ws(self):
        if QMessageBox.warning(self, "Löschen?", f"Lösche Workspace '{self.current_ws.name}'?", 
                               QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No) == QMessageBox.StandardButton.Yes:
            os.remove(self.current_ws.file)
            idx = self.cb_ws.currentIndex()
            self.cb_ws.removeItem(idx)

    def load_panels(self):
        # Panels aus Workspace laden, 3×4 Grid
        cfgs = self.current_ws.data.get("panels", [])
        rows = self.settings["grid"]["rows"]
        cols = self.settings["grid"]["cols"]
        for r in range(rows):
            for c in range(cols):
                idx = r*cols + c
                if idx < len(cfgs):
                    pnl = PanelWidget(cfgs[idx], self)
                else
                    # leere Platzhalter
                    pnl = PanelWidget({"type":"empty","title":"+"}, self)
                pnl.setFloating(False)
                self.addDockWidget(Qt.DockWidgetArea.AllDockWidgetAreas, pnl)
        self.refresh_log()

    def refresh_grid(self):
        # alte Panels entfernen, neue laden
        for w in self.findChildren(QDockWidget):
            if w.windowTitle()!="Logverlauf": self.removeDockWidget(w)
        self.load_panels()

    def refresh_log(self):
        self.log_list.clear()
        for entry in self.current_ws.data.get("log",[]):
            self.log_list.addItem(entry)

    def toggle_theme(self):
        self.settings["theme"] = "dark" if self.settings["theme"]=="light" else "light"
        self.apply_theme()
        self.save_settings()
        self.current_ws.log(f"Theme auf {self.settings['theme']} gewechselt")
        self.refresh_log()

if __name__=="__main__":
    app = QApplication(sys.argv)
    win = MainWindow()
    win.show()
    sys.exit(app.exec())
EOF

# Default-Settings
cat << 'EOF' > "$SETTINGS"
{
  "theme": "light",
  "font_size": 12,
  "grid": {"rows":3,"cols":4}
}
EOF

# Metadaten und Protokoll
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_28.txt"
ID: 28
Zeit: $STAMP
Beschreibung: Profi-GUI mit Workspaces & Panel-Manager für Laien
Dateien:
  - $GUI
  - $SETTINGS
  - Profile in $PROFILES_DIR
EOF
echo "Update 28 applied $STAMP" >> "$BASE/info-stand.txt"
md5sum "$GUI" "$SETTINGS" >> "$BASE/CHECKSUMS.txt"

echo "✅ Update 28 erfolgreich abgeschlossen."
