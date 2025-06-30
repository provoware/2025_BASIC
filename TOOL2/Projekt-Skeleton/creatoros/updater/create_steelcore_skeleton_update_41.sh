#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
START=start_gui_dashboard.sh
META=$BASE/meta/changes
INFO=$BASE/info-stand.txt
SUMS=$BASE/CHECKSUMS.txt

if [[ "${1:-}" == "--dry-run" ]]; then
  echo "[DRY RUN] Update 41: Portierung auf PySide6"
  echo " → Backup GUI & Start-Skript"
  echo " → Prüfe PySide6-Import"
  echo " → Erzeuge neue $GUI"
  echo " → Erzeuge $START"
  echo " → Syntax-Check $GUI"
  exit 0
fi

echo "=== Update 41: Dashboard auf PySide6 portieren ==="

# 1) Backups
mkdir -p "$BASE/conflicts"
for F in "$GUI" "$START"; do
  if [ -f "$F" ]; then
    cp "$F" "$BASE/conflicts/$(basename "$F").bak.$(date +%s)"
    echo "⚠️ Backup: $F → conflicts/"
  fi
done

# 2) Prüfe PySide6-Verfügbarkeit
echo "▶️ Prüfe PySide6-Verfügbarkeit…"
if python3 - <<'PYCODE' 2>/dev/null
import PySide6
PYCODE
then
  echo "   ✔ PySide6 gefunden."
else
  echo "❌ PySide6 nicht installiert! Bitte in deinem System oder venv 'pip install pyside6' ausführen."
  exit 1
fi

# 3) Schreibe neues Dashboard in PySide6
echo "▶️ Schreibe $GUI …"
mkdir -p "$(dirname "$GUI")"
cat << 'EOF' > "$GUI"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys, os, json, datetime
from PySide6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QGridLayout, QDockWidget,
    QToolBar, QComboBox, QAction, QLabel, QStatusBar, QListWidget,
    QHBoxLayout, QVBoxLayout, QFrame, QSlider
)
from PySide6.QtGui import QKeySequence, QFontDatabase
from PySide6.QtCore import Qt

# Pfade
BASE_DIR = os.path.dirname(__file__)
PROFILES_DIR = os.path.join(BASE_DIR, "profiles")
SETTINGS_FILE = os.path.join(BASE_DIR, "settings.json")
UPDATER_DIR = os.path.abspath(os.path.join(BASE_DIR, "..", "updater"))

os.makedirs(PROFILES_DIR, exist_ok=True)

# Default-Einstellungen
DEFAULT_SETTINGS = {"theme":"light","font_size":12,"grid":{"rows":3,"cols":4}}

def load_settings():
    if os.path.isfile(SETTINGS_FILE):
        return json.load(open(SETTINGS_FILE, encoding="utf-8"))
    s = DEFAULT_SETTINGS.copy()
    json.dump(s, open(SETTINGS_FILE,"w",encoding="utf-8"), indent=2)
    return s

class Workspace:
    def __init__(self, name):
        self.name = name
        self.file = os.path.join(PROFILES_DIR, f"{name}.json")
        if os.path.isfile(self.file):
            self.data = json.load(open(self.file, encoding="utf-8"))
        else:
            self.data = {"name":name, "panels":[], "log":[]}
        self.log(f"Workspace '{name}' geladen")
    def save(self):
        self.data["last_saved"] = datetime.datetime.now().isoformat()
        json.dump(self.data, open(self.file,"w",encoding="utf-8"), indent=2)
        self.log("Workspace gespeichert")
    def log(self, msg):
        ts = datetime.datetime.now().strftime("%H:%M:%S")
        entry = f"[{ts}] {msg}"
        self.data["log"].insert(0, entry)
        if len(self.data["log"])>100: self.data["log"].pop()
        return entry

class PanelWidget(QFrame):
    def __init__(self, cfg, parent=None):
        super().__init__(parent)
        self.cfg = cfg
        try:
            self.setFrameShape(QFrame.Shape.StyledPanel)
        except Exception:
            pass
        layout = QVBoxLayout(self)
        layout.addWidget(QLabel(f"<b>Typ:</b> {cfg.get('type','')}"))
        layout.addWidget(QLabel(f"<b>Einstellungen:</b> {cfg.get('config','')}"))
        layout.setContentsMargins(5,5,5,5)

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Steel-Core Profi-Dashboard (PySide6)")
        self.settings = load_settings()
        self._apply_theme()
        # Workspace
        names = [f[:-5] for f in os.listdir(PROFILES_DIR) if f.endswith(".json")]
        if not names: names=["Default"]
        self.current_ws = Workspace(names[0])
        # Toolbar
        tb = QToolBar("Haupt", self); self.addToolBar(tb)
        self.cb = QComboBox(); self.cb.addItems(names)
        self.cb.currentTextChanged.connect(self._switch_ws)
        tb.addWidget(self.cb)
        tb.addAction(QAction("Neu", self, triggered=self._new_ws))
        tb.addAction(QAction("Duplizieren", self, triggered=self._dup_ws))
        tb.addAction(QAction("Löschen", self, triggered=self._del_ws))
        tb.addSeparator()
        tb.addAction(QAction("Theme", self, triggered=self._toggle_theme))
        tb.addAction(QAction("Speichern", self, triggered=self.current_ws.save))
        # Font-Slider
        slider = QSlider(Qt.Orientation.Horizontal, self)
        slider.setRange(8,32)
        slider.setValue(self.settings.get("font_size",12))
        slider.valueChanged.connect(self._change_font_size)
        tb.addWidget(slider)
        # Central Grid
        cw = QWidget(self); self.setCentralWidget(cw)
        gl = QGridLayout(cw); gl.setContentsMargins(10,10,10,10)
        rows,cols = self.settings["grid"]["rows"], self.settings["grid"]["cols"]
        self.panels=[]
        for i in range(rows*cols):
            cfg = self.current_ws.data.get("panels",[])[i] if i<len(self.current_ws.data.get("panels",[])) else {"type":"leer","config":""}
            w = PanelWidget(cfg,self)
            gl.addWidget(w, i//cols, i%cols)
            self.panels.append(w)
        # Log-Dock
        dock = QDockWidget("Logverlauf", self)
        self.log_list = QListWidget()
        dock.setWidget(self.log_list)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, dock)
        self._refresh_log()
        # Update-Manager Dock
        upd = QDockWidget("Updates", self)
        lst = QListWidget()
        for f in sorted(os.listdir(UPDATER_DIR)):
            if f.startswith("create_steelcore_skeleton_update"):
                lst.addItem(f)
        upd.setWidget(lst)
        self.addDockWidget(Qt.DockWidgetArea.LeftDockWidgetArea, upd)

    def _apply_theme(self):
        if self.settings["theme"]=="dark":
            self.setStyleSheet("QMainWindow{background:#2e2e2e;color:#ddd}")
        elif self.settings["theme"]=="contrast":
            self.setStyleSheet("QMainWindow{background:#000;color:#fff}")
        else:
            self.setStyleSheet("")

    def _switch_ws(self, name):
        self.current_ws = Workspace(name); self._refresh_log()

    def _new_ws(self):
        fn,_ = QFileDialog.getSaveFileName(self,"Neuer Workspace",PROFILES_DIR,"JSON (*.json)")
        if fn:
            base = os.path.splitext(os.path.basename(fn))[0]
            self.current_ws = Workspace(base)
            self.cb.addItem(base); self.cb.setCurrentText(base)
            self._refresh_log()

    def _dup_ws(self):
        base = self.current_ws.name + "_copy"
        ws = Workspace(base); ws.data = json.loads(json.dumps(self.current_ws.data)); ws.save()
        self.cb.addItem(base); self.cb.setCurrentText(base); self._refresh_log()

    def _del_ws(self):
        if QMessageBox.question(self,"Löschen?",f"Lösche '{self.current_ws.name}'?")==QMessageBox.StandardButton.Yes:
            os.remove(self.current_ws.file)
            self.cb.removeItem(self.cb.currentIndex())
            self._switch_ws(self.cb.currentText())

    def _toggle_theme(self):
        tlist = ["light","dark","contrast"]
        idx = tlist.index(self.settings["theme"])
        self.settings["theme"] = tlist[(idx+1)%3]
        json.dump(self.settings, open(SETTINGS_FILE,"w"), indent=2)
        self._apply_theme()

    def _change_font_size(self, val):
        size = int(val)
        self.settings["font_size"] = size
        font = QFontDatabase.systemFont(QFontDatabase.SystemFont.TitleFont)
        font.setPointSize(size)
        QApplication.instance().setFont(font)
        json.dump(self.settings, open(SETTINGS_FILE,"w"), indent=2)

    def _refresh_log(self):
        self.log_list.clear()
        for e in self.current_ws.data.get("log",[]):
            self.log_list.addItem(e)

if __name__=="__main__":
    app = QApplication(sys.argv)
    w = MainWindow(); w.show()
    sys.exit(app.exec())
EOF
chmod +x "$GUI"

# 4) Rewrite start script
echo "▶️ Erzeuge $START …"
cat << 'EOF' > "$START"
#!/usr/bin/env bash
set -euo pipefail
python3 creatoros/interface/steelcore_dashboard.py
EOF
chmod +x "$START"

# 5) Syntax-Check
echo "▶️ Syntax-Validierung…"
python3 -m py_compile "$GUI" && echo "   ✔ No syntax errors." || { echo "❌ Syntax errors!"; exit 1; }

# 6) Metadaten & Checksums
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_41.txt"
ID: 41
Zeit: $STAMP
Beschreibung: Portierung des Dashboards auf PySide6, alle Grundfunktionen integriert
Dateien:
  - $GUI
  - $START
EOF
echo "Update 41 applied $STAMP" >> "$INFO"
md5sum "$GUI" "$START" >> "$SUMS"

echo "✅ Update 41 erfolgreich abgeschlossen. Jetzt: bash start_gui_dashboard.sh"
