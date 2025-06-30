#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
START=start_gui_dashboard.sh
SETTINGS=creatoros/interface/settings.json
PROFILES=creatoros/interface/profiles
META=$BASE/meta/changes
CHECK=creatoros/updater/CHECKSUMS.txt

echo "=== Update 29: Profi-GUI-Korrektur & Optimierung ==="

# 1) Verzeichnisse anlegen
echo "▶️ 1. Validierung der Ordnerstruktur..."
mkdir -p "$(dirname "$GUI")" "$PROFILES" "$META"
echo "   ✔ Ordner vorhanden/erstellt."

# 2) Backup vorhandener Dateien
for F in "$GUI" "$SETTINGS" "$START"; do
  if [ -f "$F" ]; then
    mv "$F" "$BASE/conflicts/$(basename "$F").bak.$(date +%s)"
    echo "   ⚠️ Backup: $F → conflicts/"
  fi
done

# 3) Profi-GUI schreiben
echo "▶️ 2. Schreiben der korrigierten GUI (steelcore_dashboard.py)..."
cat << 'EOF' > "$GUI"
# -*- coding: utf-8 -*-
import sys, os, json, datetime
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QGridLayout, QDockWidget,
    QAction, QToolBar, QComboBox, QMessageBox, QFileDialog, QPushButton,
    QLabel, QStatusBar, QListWidget, QVBoxLayout
)
from PyQt6.QtCore import Qt

def resource_path(rel):
    return os.path.join(os.path.dirname(__file__), rel)

SETTINGS_FILE = resource_path("settings.json")
PROFILES_DIR = resource_path("profiles")
if not os.path.isdir(PROFILES_DIR):
    os.makedirs(PROFILES_DIR, exist_ok=True)

DEFAULT_SETTINGS = {
    "theme": "light",
    "font_size": 12,
    "grid": {"rows":3, "cols":4},
}

class Workspace:
    def __init__(self, name):
        self.name = name
        self.file = os.path.join(PROFILES_DIR, f"{name}.json")
        if os.path.isfile(self.file):
            self.data = json.load(open(self.file, encoding="utf-8"))
        else:
            self.data = {"name":name, "panels":[], "log":[], "last_saved":None}
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
        w = QWidget()
        lay = QVBoxLayout()
        lay.addWidget(QLabel(f"<b>Typ:</b> {cfg.get('type','–')}"))
        lay.addWidget(QLabel(f"<b>Einstellungen:</b> {cfg.get('config','–')}"))
        w.setLayout(lay)
        self.setWidget(w)

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Steel-Core Profi-Dashboard")
        self.resize(1280,900)
        self.status = QStatusBar(); self.setStatusBar(self.status)

        self.settings = self.load_settings()
        self.apply_theme()

        # Workspaces laden/erstellen
        names = [f[:-5] for f in os.listdir(PROFILES_DIR) if f.endswith(".json")]
        if not names: names=["Default"]
        self.current_ws = Workspace(names[0])

        # Toolbar mit Workspace-Combo und Aktionen
        tb = QToolBar("Haupt"); self.addToolBar(tb)
        self.cb = QComboBox(); self.cb.addItems(names); self.cb.currentTextChanged.connect(self.switch_ws)
        tb.addWidget(self.cb)
        tb.addAction("Neu", self.action_new_ws)
        tb.addAction("Duplizieren", self.action_dup_ws)
        tb.addAction("Löschen", self.action_del_ws)
        tb.addSeparator()
        tb.addAction("Theme", self.toggle_theme)
        tb.addAction("Speichern", self.current_ws.save)

        # Grid-Center und Panels laden
        central = QWidget(); self.grid = QGridLayout(); central.setLayout(self.grid)
        self.setCentralWidget(central)
        self.load_panels()

        # Log-Dock
        dock = QDockWidget("Logverlauf", self)
        self.log_list = QListWidget(); dock.setWidget(self.log_list)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, dock)
        self.refresh_log()

    def load_settings(self):
        if os.path.isfile(SETTINGS_FILE):
            return json.load(open(SETTINGS_FILE, encoding="utf-8"))
        return DEFAULT_SETTINGS.copy()

    def save_settings(self):
        json.dump(self.settings, open(SETTINGS_FILE,"w",encoding="utf-8"), indent=2)

    def apply_theme(self):
        pal = self.palette()
        if self.settings.get("theme")=="dark":
            pal.setColor(self.backgroundRole(), Qt.GlobalColor.black)
            pal.setColor(self.foregroundRole(), Qt.GlobalColor.white)
        else:
            pal.setColor(self.backgroundRole(), Qt.GlobalColor.white)
            pal.setColor(self.foregroundRole(), Qt.GlobalColor.black)
        self.setPalette(pal)

    def switch_ws(self, name):
        self.current_ws = Workspace(name)
        self.refresh_grid(); self.refresh_log()

    def action_new_ws(self):
        fn, _ = QFileDialog.getSaveFileName(self,"Neuer Workspace",PROFILES_DIR,"JSON (*.json)")
        [self.switch_ws(os.path.splitext(os.path.basename(fn))[0])] if fn else None

    def action_dup_ws(self):
        base = self.current_ws.name+"_copy"
        ws = Workspace(base); ws.data=self.current_ws.data.copy(); ws.save()
        self.cb.addItem(base); self.cb.setCurrentText(base)

    def action_del_ws(self):
        if QMessageBox.question(self,"Löschen?",f"Lösche '{self.current_ws.name}'?")\
           == QMessageBox.StandardButton.Yes:
            os.remove(self.current_ws.file)
            idx = self.cb.currentIndex(); self.cb.removeItem(idx)

    def load_panels(self):
        rows = self.settings["grid"]["rows"]; cols = self.settings["grid"]["cols"]
        cfgs = self.current_ws.data.get("panels", [])
        # alte rausnehmen
        for w in self.findChildren(QDockWidget):
            if w.windowTitle()!="Logverlauf": self.removeDockWidget(w)
        # neu hinzufügen
        for r in range(rows):
            for c in range(cols):
                idx=r*cols+c
                cfg = cfgs[idx] if idx<len(cfgs) else {"type":"leer","title":"+"}
                pnl=PanelWidget(cfg,self)
                self.addDockWidget(Qt.DockWidgetArea.AllDockWidgetAreas,pnl)
        self.refresh_log()

    def refresh_grid(self): self.load_panels()
    def refresh_log(self):
        self.log_list.clear()
        for e in self.current_ws.data.get("log",[]): self.log_list.addItem(e)

    def toggle_theme(self):
        t = "dark" if self.settings["theme"]=="light" else "light"
        self.settings["theme"]=t; self.apply_theme(); self.save_settings()
        self.current_ws.log(f"Theme → {t}"); self.refresh_log()

if __name__=="__main__":
    app=QApplication(sys.argv); w=MainWindow(); w.show(); sys.exit(app.exec())
EOF
echo "   ✔ steelcore_dashboard.py geschrieben."

# 4) Start-Skript anlegen
echo "▶️ 3. Start-Skript erstellen..."
cat << EOF > "$START"
#!/usr/bin/env bash
set -euo pipefail
# aus Projekt-Root ausführen!
python3 creatoros/interface/steelcore_dashboard.py
EOF
chmod +x "$START"
echo "   ✔ $START erstellt."

# 5) Settings neu initialisieren
echo "▶️ 4. Default-Settings prüfen..."
if [ ! -f "$SETTINGS" ]; then
  cat << JSON > "$SETTINGS"
{
  "theme":"light","font_size":12,
  "grid":{"rows":3,"cols":4}
}
JSON
  echo "   ✔ Default settings.json angelegt."
else
  echo "   ✔ settings.json existiert, wird nicht überschrieben."
fi

# 6) Syntax-Check
echo "▶️ 5. Syntax-Validierung..."
python3 -m py_compile "$GUI" && echo "   ✔ Keine Syntaxfehler." || { echo "❌ Syntax-Fehler in steelcore_dashboard.py!"; exit 1; }

# 7) Metadaten & Checksum
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_29.txt"
ID: 29
Zeit: $STAMP
Beschreibung: Profi-GUI Bugfix & Optimierung für Laien
Dateien:
  - $GUI
  - $START
  - $SETTINGS (wenn neu)
EOF
echo "Update 29 applied $STAMP" >> creatoros/updater/info-stand.txt
md5sum "$GUI" "$START" >> "$CHECK"

echo "✅ Update 29 vollständig abgeschlossen."
