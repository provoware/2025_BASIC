#!/usr/bin/env bash
set -euo pipefail

# Update 40: Komplettes tkinter-Dashboard mit Profi-Features
BASE=creatoros/updater
GUI=creatoros/interface/steelcore_dashboard.py
START=start_gui_dashboard.sh
SETTINGS=creatoros/interface/settings.json
PROFILES=creatoros/interface/profiles
THEMES=creatoros/interface/themes
META=$BASE/meta/changes
INFO=$BASE/info-stand.txt
SUMS=$BASE/CHECKSUMS.txt

DRY_RUN=${1:-}

if [ "$DRY_RUN" = "--dry-run" ]; then
  echo "[DRY RUN] Update 40: tkinter-Dashboard generieren"
  echo " → Backup steelcore_dashboard.py"
  echo " → Backup start_gui_dashboard.sh"
  echo " → Erzeuge $GUI"
  echo " → Erzeuge $START"
  echo " → Prüfe python3 -c 'import tkinter, json'"
  echo " → Prüfe python3 -m py_compile $GUI"
  exit 0
fi

echo "=== Update 40: Bereite tkinter-Dashboard vor ==="

# 1) Backup existierender Dateien
mkdir -p "$BASE/conflicts"
for F in "$GUI" "$START"; do
  if [ -f "$F" ]; then
    cp "$F" "$BASE/conflicts/$(basename "$F").bak.$(date +%s)"
    echo "⚠️ Backup: $F → conflicts/"
  fi
done

# 2) Ordner anlegen
mkdir -p "$(dirname "$GUI")" "$PROFILES" "$THEMES" "$META"
echo "✔ Ordnerstruktur OK."

# 3) Dashboard-Code schreiben
cat << 'EOF' > "$GUI"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import tkinter as tk
from tkinter import ttk, font, filedialog, messagebox
import os, json, datetime, glob

# Pfade
BASE_DIR = os.path.abspath(os.path.join(__file__, ".."))
SETTINGS_FILE = os.path.join(BASE_DIR, "settings.json")
PROFILES_DIR = os.path.join(BASE_DIR, "profiles")
THEMES_DIR = os.path.join(BASE_DIR, "themes")

os.makedirs(PROFILES_DIR, exist_ok=True)
os.makedirs(THEMES_DIR, exist_ok=True)

# Default-Einstellungen
DEFAULT_SETTINGS = {
    "theme": "light",
    "font_size": 12,
    "grid": {"rows": 3, "cols": 4},
    "themes": ["light", "dark", "contrast"]
}

def load_settings():
    if os.path.isfile(SETTINGS_FILE):
        return json.load(open(SETTINGS_FILE, "r", encoding="utf-8"))
    data = DEFAULT_SETTINGS.copy()
    json.dump(data, open(SETTINGS_FILE, "w", encoding="utf-8"), indent=2)
    return data

class Workspace:
    def __init__(self, name):
        self.name = name
        self.file = os.path.join(PROFILES_DIR, f"{name}.json")
        if os.path.isfile(self.file):
            self.data = json.load(open(self.file, encoding="utf-8"))
        else:
            self.data = {"name": name, "panels": [], "log": []}
        self.log(f"Workspace '{name}' geladen")

    def save(self):
        self.data["last_saved"] = datetime.datetime.now().isoformat()
        json.dump(self.data, open(self.file, "w", encoding="utf-8"), indent=2)
        self.log("Workspace gespeichert")
        messagebox.showinfo("Speichern", f"Workspace '{self.name}' gespeichert.")

    def log(self, msg):
        ts = datetime.datetime.now().strftime("%H:%M:%S")
        entry = f"[{ts}] {msg}"
        self.data["log"].insert(0, entry)
        if len(self.data["log"]) > 100:
            self.data["log"].pop()
        return entry

class Dashboard(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Steel-Core Profi-Dashboard (tkinter)")
        # Load settings & theme
        self.settings = load_settings()
        self._apply_theme()
        base_font = font.nametofont("TkDefaultFont")
        base_font.configure(size=self.settings["font_size"])
        # Toolbar
        toolbar = ttk.Frame(self, padding=4)
        toolbar.pack(side=tk.TOP, fill=tk.X)
        # Workspace Combobox
        names = [os.path.splitext(os.path.basename(f))[0]
                 for f in glob.glob(os.path.join(PROFILES_DIR, "*.json"))]
        if not names: names = ["Default"]
        self.ws = Workspace(names[0])
        self.cb_ws = ttk.Combobox(toolbar, values=names, state="readonly")
        self.cb_ws.set(self.ws.name)
        self.cb_ws.pack(side=tk.LEFT, padx=2)
        self.cb_ws.bind("<<ComboboxSelected>>", self._switch_ws)
        ttk.Button(toolbar, text="Neu", command=self._new_ws).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Duplizieren", command=self._dup_ws).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Löschen", command=self._del_ws).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Speichern", command=self.ws.save).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Theme", command=self._toggle_theme).pack(side=tk.LEFT, padx=2)
        # Font slider
        self.slider = ttk.Scale(toolbar, from_=8, to=32,
                                command=self._change_font_size)
        self.slider.set(self.settings["font_size"])
        self.slider.pack(side=tk.RIGHT, padx=2)
        # Main frame
        main = ttk.Frame(self)
        main.pack(fill=tk.BOTH, expand=True)
        # Update-Manager (links)
        upd_frame = ttk.LabelFrame(main, text="Updates", width=200)
        upd_frame.pack(side=tk.LEFT, fill=tk.Y, padx=2, pady=2)
        self.lst_updates = tk.Listbox(upd_frame)
        for f in sorted(os.listdir(os.path.join(BASE_DIR, "..", "updater"))):
            if f.startswith("create_steelcore_skeleton_update"):
                self.lst_updates.insert(tk.END, f)
        self.lst_updates.pack(fill=tk.BOTH, expand=True)
        # Grid (Mitte)
        grid_frame = ttk.Frame(main)
        grid_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=2, pady=2)
        rows = self.settings["grid"]["rows"]
        cols = self.settings["grid"]["cols"]
        for r in range(rows):
            grid_frame.rowconfigure(r, weight=1)
        for c in range(cols):
            grid_frame.columnconfigure(c, weight=1)
        self.panels = []
        for idx in range(rows*cols):
            frm = ttk.Frame(grid_frame, relief=tk.RIDGE, borderwidth=2)
            frm.grid(row=idx//cols, column=idx%cols, sticky="nsew", padx=2, pady=2)
            lbl = ttk.Label(frm, text="+", anchor="center")
            lbl.pack(expand=True)
            self.panels.append(frm)
        # Log-Panel (rechts)
        log_frame = ttk.LabelFrame(main, text="Log")
        log_frame.pack(side=tk.RIGHT, fill=tk.Y, padx=2, pady=2)
        self.txt_log = tk.Text(log_frame, width=30, state="disabled")
        self.txt_log.pack(fill=tk.BOTH, expand=True)
        self._refresh_log()
        # Keyboard shortcuts
        self.bind_all("<Control-s>", lambda e: self.ws.save())
        self.bind_all("<Control-n>", lambda e: self._new_ws())
        self.bind_all("<Control-d>", lambda e: self._toggle_theme())

    def _apply_theme(self):
        th = self.settings["theme"]
        style = ttk.Style()
        style.theme_use("clam")
        if th == "dark":
            style.configure(".", background="#2e2e2e", foreground="#dddddd")
        elif th == "contrast":
            style.configure(".", background="#000000", foreground="#ffffff")
        # light = default

    def _switch_ws(self, event=None):
        name = self.cb_ws.get()
        self.ws = Workspace(name)
        self._refresh_log()

    def _new_ws(self):
        name = filedialog.asksaveasfilename(initialdir=PROFILES_DIR,
            title="Neuer Workspace", defaultextension=".json", filetypes=[("JSON","*.json")])
        if name:
            base = os.path.splitext(os.path.basename(name))[0]
            self.ws = Workspace(base)
            self.cb_ws["values"] = (*self.cb_ws["values"], base)
            self.cb_ws.set(base)
            self._refresh_log()

    def _dup_ws(self):
        base = self.ws.name + "_copy"
        new = Workspace(base)
        new.data = json.loads(json.dumps(self.ws.data))
        new.save()
        vs = list(self.cb_ws["values"]) + [base]
        self.cb_ws["values"] = vs
        self.cb_ws.set(base)
        self.ws = new
        self._refresh_log()

    def _del_ws(self):
        if messagebox.askyesno("Löschen", f"Lösche {self.ws.name}?"):
            os.remove(self.ws.file)
            vals = list(self.cb_ws["values"])
            vals.remove(self.ws.name)
            self.cb_ws["values"] = vals
            self.cb_ws.set(vals[0] if vals else "")
            self.ws = Workspace(self.cb_ws.get())
            self._refresh_log()

    def _toggle_theme(self):
        ths = DEFAULT_SETTINGS["themes"]
        idx = ths.index(self.settings["theme"])
        self.settings["theme"] = ths[(idx+1)%len(ths)]
        json.dump(self.settings, open(SETTINGS_FILE,"w"), indent=2)
        self._apply_theme()

    def _change_font_size(self, val):
        size = int(float(val))
        self.settings["font_size"] = size
        font.nametofont("TkDefaultFont").configure(size=size)
        json.dump(self.settings, open(SETTINGS_FILE,"w"), indent=2)

    def _refresh_log(self):
        self.txt_log.config(state="normal")
        self.txt_log.delete("1.0", tk.END)
        for entry in self.ws.data.get("log", []):
            self.txt_log.insert(tk.END, entry + "\n")
        self.txt_log.config(state="disabled")

if __name__ == "__main__":
    # Test Imports
    import tkinter, json
    # Start
    dash = Dashboard()
    dash.mainloop()
EOF
chmod +x "$GUI"
echo "✔ $GUI geschrieben."

# 4) Start-Skript erzeugen
cat << EOF > "$START"
#!/usr/bin/env bash
set -euo pipefail
python3 creatoros/interface/steelcore_dashboard.py
EOF
chmod +x "$START"
echo "✔ $START erstellt."

# 5) Syntax- & Modul-Check
echo "▶️ Prüfe tkinter-Verfügbarkeit…"
if python3 - <<'PY' 2>/dev/null
import tkinter, ttk, json
PY
then
  echo "   ✔ tkinter & ttk verfügbar."
else
  echo "❌ tkinter/ttk fehlt!"
  exit 1
fi

echo "▶️ Syntax-Validierung…"
python3 -m py_compile "$GUI" && echo "   ✔ Keine Syntaxfehler." || { echo "❌ Syntax-Fehler!"; exit 1; }

# 6) Metadaten & Checksums
STAMP=$(date --iso-8601=seconds)
cat << EOF > "$META/change_40.txt"
ID: 40
Zeit: $STAMP
Beschreibung: Vollständiges tkinter-Dashboard mit Profi-Funktionen
Dateien:
  - $GUI
  - $START
EOF
echo "Update 40 applied $STAMP" >> "$INFO"
md5sum "$GUI" "$START" >> "$SUMS"

echo "✅ Update 40 erfolgreich abgeschlossen."
