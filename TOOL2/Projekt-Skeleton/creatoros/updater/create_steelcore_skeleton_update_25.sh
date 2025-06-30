#!/usr/bin/env bash
set -euo pipefail
GUIFILE=creatoros/interface/steelcore_dashboard.py
SETTINGS=creatoros/interface/settings.json

cat <<'EOF' > "$GUIFILE"
# -*- coding: utf-8 -*-
import tkinter as tk
from tkinter import ttk, messagebox
import json, os, datetime, subprocess

STATE_FILE = "creatoros/interface/.grid_state.json"
LOG_FILE = "creatoros/interface/dashboard.log"
SETTINGS_FILE = "creatoros/interface/settings.json"
UPDATER_PATH = "creatoros/updater"

DEFAULT_SETTINGS = {
    "theme": "light",
    "sidebar": True,
    "modules": [True]*12,
    "font_size": 12
}

class Logger:
    def __init__(self, textbox):
        self.textbox = textbox

    def log(self, msg):
        timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        full_msg = f"[{timestamp}] {msg}"
        self.textbox.insert(tk.END, full_msg + '\\n')
        self.textbox.see(tk.END)
        with open(LOG_FILE, "a") as f:
            f.write(full_msg + '\\n')

class SteelCoreDashboard(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Steel-Core Dashboard")
        self.geometry("1320x870")
        self.drag_data = {"widget": None, "x": 0, "y": 0}
        self.modules = []
        self.module_checks = []
        self.logger = None
        self.settings = self.load_settings()
        self.theme = self.settings.get("theme", "light")

        try:
            self.setup_ui()
            self.check_for_updates()
        except Exception as e:
            self.fatal_error("Fehler beim Start", e)

    def load_settings(self):
        if os.path.exists(SETTINGS_FILE):
            with open(SETTINGS_FILE) as f:
                s = json.load(f)
            # Backwards-compat: immer alle keys setzen
            for k,v in DEFAULT_SETTINGS.items():
                if k not in s: s[k]=v
            return s
        else:
            return DEFAULT_SETTINGS.copy()

    def save_settings(self):
        with open(SETTINGS_FILE, "w") as f:
            json.dump(self.settings, f)

    def setup_ui(self):
        self.create_header()
        self.create_sidebars()
        self.create_main()
        self.create_footer()
        self.configure_theme()
        self.load_positions()
        self.set_module_visibility()
        self.logger.log("GUI und Einstellungen geladen.")

    def create_header(self):
        self.header = ttk.Frame(self)
        self.header.pack(fill=tk.X)
        self.status_label = ttk.Label(self.header, text="Status: Starte...", font=("Arial", 14, "bold"))
        self.status_label.pack(side=tk.LEFT, padx=10)
        ttk.Button(self.header, text="🔄 Theme", command=self.toggle_theme).pack(side=tk.RIGHT)
        ttk.Button(self.header, text="Aa", command=self.toggle_fontsize).pack(side=tk.RIGHT, padx=2)
        ttk.Button(self.header, text="💾 Save", command=self.save_positions).pack(side=tk.RIGHT)

    def create_sidebars(self):
        # Left: Dockbar mit Modul-Checkliste
        self.sidebar_left = ttk.Frame(self)
        self.sidebar_left.pack(side=tk.LEFT, fill=tk.Y)
        ttk.Label(self.sidebar_left, text="Module anzeigen:", font=("Arial", 11, "bold")).pack(pady=5)
        self.module_vars = []
        for i in range(12):
            v = tk.BooleanVar(value=self.settings.get("modules",[True]*12)[i])
            cb = ttk.Checkbutton(self.sidebar_left, text=f"Modul {i+1}", variable=v, command=self.set_module_visibility)
            cb.pack(anchor="w")
            self.module_vars.append(v)
            self.module_checks.append(cb)
        ttk.Separator(self.sidebar_left).pack(fill=tk.X, pady=8)
        ttk.Button(self.sidebar_left, text="🧰 Update-Manager", command=self.toggle_updater).pack(pady=4)
        ttk.Button(self.sidebar_left, text="⏹️ Sidebar", command=self.toggle_sidebar).pack(pady=4)

    def create_main(self):
        main_frame = ttk.Frame(self)
        main_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=6, pady=8)
        self.grid_area = ttk.Frame(main_frame)
        self.grid_area.pack(fill=tk.BOTH, expand=True)

        font_size = self.settings.get("font_size", 12)
        for i in range(12):
            mod = tk.Label(self.grid_area, text=f"Modul {i+1}", bg="#f0f0f0", relief="raised", bd=1, font=("Arial", font_size, "bold"))
            mod.place(x=20+(i%4)*300, y=20+(i//4)*200, width=280, height=180)
            mod.bind("<ButtonPress-1>", self.on_drag_start)
            mod.bind("<B1-Motion>", self.on_drag_motion)
            mod.bind("<ButtonRelease-1>", self.on_drag_release)
            mod.bind("<Enter>", lambda e, ix=i: self.show_tooltip(ix))
            mod.bind("<Leave>", lambda e: self.hide_tooltip())
            self.modules.append(mod)

        log_frame = ttk.Frame(main_frame)
        log_frame.pack(side=tk.RIGHT, fill=tk.Y)
        ttk.Label(log_frame, text="📋 Log-Ausgabe").pack()
        self.log_box = tk.Text(log_frame, width=38, height=32, font=("Consolas", 10))
        self.log_box.pack()
        self.logger = Logger(self.log_box)
        self.tooltip = None

    def create_footer(self):
        footer = ttk.Frame(self)
        footer.pack(fill=tk.X)
        for i in range(4):
            ttk.Label(footer, text=f"F{i+1}").grid(row=0, column=i, sticky="ew")
            footer.columnconfigure(i, weight=1)

    def toggle_theme(self):
        self.theme = "dark" if self.theme == "light" else "light"
        self.settings["theme"] = self.theme
        self.configure_theme()
        self.logger.log(f"Theme gewechselt zu: {self.theme}")
        self.save_settings()

    def toggle_fontsize(self):
        # 12 <-> 18pt für Barrierefreiheit
        self.settings["font_size"] = 18 if self.settings.get("font_size", 12)==12 else 12
        for widget in self.modules:
            widget.config(font=("Arial", self.settings["font_size"], "bold"))
        self.logger.log("Font-Size gewechselt.")
        self.save_settings()

    def set_module_visibility(self):
        vis = [v.get() for v in self.module_vars]
        self.settings["modules"] = vis
        for i, show in enumerate(vis):
            self.modules[i].place_forget() if not show else self.modules[i].place(x=20+(i%4)*300, y=20+(i//4)*200, width=280, height=180)
        self.logger.log("Modul-Sichtbarkeit aktualisiert.")
        self.save_settings()

    def toggle_sidebar(self):
        # Left-Sidebar ein/aus
        if self.sidebar_left.winfo_ismapped():
            self.sidebar_left.pack_forget()
            self.settings["sidebar"] = False
        else:
            self.sidebar_left.pack(side=tk.LEFT, fill=tk.Y)
            self.settings["sidebar"] = True
        self.logger.log("Sidebar-Sichtbarkeit umgeschaltet.")
        self.save_settings()

    def check_for_updates(self):
        # Bei Start Updates prüfen und anzeigen
        try:
            applied = []
            info_path = os.path.join(UPDATER_PATH, "info-stand.txt")
            if os.path.isfile(info_path):
                with open(info_path) as f:
                    for line in f:
                        if line.startswith("Update"):
                            applied.append(line.split()[1])
            available = sorted(f for f in os.listdir(UPDATER_PATH) if f.startswith("create_steelcore_skeleton_update_") and f.endswith(".sh"))
            missing = []
            for file in available:
                uid = file.split("_")[-1].replace(".sh", "")
                if uid not in applied:
                    missing.append(file)
            if missing:
                self.status_label.config(text=f"⚠️ {len(missing)} neue Updates verfügbar!", foreground="orange")
                self.logger.log(f"{len(missing)} Updates gefunden: {missing}")
                self.after(2000, lambda: self.auto_notify_updates(missing))
            else:
                self.status_label.config(text="✅ Alles aktuell.", foreground="green")
                self.logger.log("Update-Prüfung: System ist aktuell.")
        except Exception as e:
            self.status_label.config(text="❌ Fehler bei Update-Prüfung", foreground="red")
            self.logger.log(f"Fehler bei Update-Prüfung: {e}")

    def auto_notify_updates(self, missing):
        msg = "Folgende Updates können installiert werden:\\n" + "\\n".join(missing) + "\\n\\nJetzt anwenden?"
        if messagebox.askyesno("Neue Updates gefunden!", msg):
            for file in missing:
                path = os.path.join(UPDATER_PATH, file)
                try:
                    subprocess.run(["bash", path], check=True)
                    self.logger.log(f"✅ {os.path.basename(file)} erfolgreich installiert.")
                except subprocess.CalledProcessError as e:
                    self.logger.log(f"❌ Fehler beim Anwenden von {file}: {e}")
            self.status_label.config(text="✅ Alle Updates angewendet!", foreground="green")
        else:
            self.status_label.config(text=f"⚠️ Updates übersprungen.", foreground="orange")

    def toggle_updater(self):
        update_window = tk.Toplevel(self)
        update_window.title("Update-Manager")
        update_window.geometry("640x420")
        ttk.Label(update_window, text="Verfügbare Updates", font=("Arial", 12)).pack(pady=10)
        frame = ttk.Frame(update_window)
        frame.pack(fill=tk.BOTH, expand=True)
        applied = []
        info_path = os.path.join(UPDATER_PATH, "info-stand.txt")
        if os.path.isfile(info_path):
            with open(info_path) as f:
                for line in f:
                    if line.startswith("Update"):
                        applied.append(line.split()[1])
        updates = sorted(f for f in os.listdir(UPDATER_PATH) if f.startswith("create_steelcore_skeleton_update_") and f.endswith(".sh"))
        for up in updates:
            uid = up.split("_")[-1].replace(".sh", "")
            path = os.path.join(UPDATER_PATH, up)
            status = "✅" if uid in applied else "🟡"
            b = ttk.Button(frame, text=f"{status} {up}", command=lambda p=path: self.run_update_script(p))
            b.pack(fill=tk.X, padx=10, pady=2)

    def run_update_script(self, script_path):
        try:
            subprocess.run(["bash", script_path], check=True)
            self.logger.log(f"✅ {os.path.basename(script_path)} ausgeführt.")
        except subprocess.CalledProcessError as e:
            self.logger.log(f"❌ Fehler beim Ausführen von {script_path}: {e}")

    def configure_theme(self):
        bg = "#222" if self.theme == "dark" else "#fff"
        fg = "#eee" if self.theme == "dark" else "#000"
        font_size = self.settings.get("font_size", 12)
        for widget in self.modules:
            widget.config(bg=bg, fg=fg, font=("Arial", font_size, "bold"))
        self.log_box.config(bg="#222" if self.theme=="dark" else "#f8f8f8", fg=fg)
        self.status_label.config(background=bg, foreground=fg)
        self.save_settings()

    def save_positions(self):
        try:
            state = [{"x": m.winfo_x(), "y": m.winfo_y(), "text": m.cget("text")} for m in self.modules]
            with open(STATE_FILE, "w") as f:
                json.dump(state, f)
            self.logger.log("📌 Positionen gespeichert.")
        except Exception as e:
            self.fatal_error("Fehler beim Speichern", e)

    def load_positions(self):
        if os.path.exists(STATE_FILE):
            try:
                with open(STATE_FILE, "r") as f:
                    state = json.load(f)
                for widget, saved in zip(self.modules, state):
                    widget.place(x=saved["x"], y=saved["y"])
                self.logger.log("↩️ Positionen geladen.")
            except Exception as e:
                self.logger.log("⚠️ Layout konnte nicht geladen werden.")
                self.logger.log(str(e))

    def on_drag_start(self, event):
        self.drag_data["widget"] = event.widget
        self.drag_data["x"] = event.x
        self.drag_data["y"] = event.y

    def on_drag_motion(self, event):
        w = self.drag_data["widget"]
        if w:
            x = w.winfo_x() - self.drag_data["x"] + event.x
            y = w.winfo_y() - self.drag_data["y"] + event.y
            w.place(x=x, y=y)

    def on_drag_release(self, event):
        self.drag_data["widget"] = None

    def show_tooltip(self, ix):
        txt = f"Dies ist Modul {ix+1}.\\nAktivieren/deaktivieren per Sidebar."
        if self.tooltip: self.tooltip.destroy()
        x = self.modules[ix].winfo_rootx() + 40
        y = self.modules[ix].winfo_rooty() + 40
        self.tooltip = tw = tk.Toplevel(self.modules[ix])
        tw.wm_overrideredirect(True)
        tw.wm_geometry(f"+{x}+{y}")
        label = tk.Label(tw, text=txt, background="yellow", relief="solid", borderwidth=1, font=("Arial", 12))
        label.pack()

    def hide_tooltip(self):
        if self.tooltip:
            self.tooltip.destroy()
            self.tooltip = None

    def fatal_error(self, msg, err):
        import traceback
        traceback.print_exc()
        messagebox.showerror("Fehler", f"{msg}: {err}")
        self.logger and self.logger.log(f"❌ {msg}: {err}")
        self.destroy()

if __name__ == "__main__":
    app = SteelCoreDashboard()
    app.mainloop()
EOF

if [ ! -f "$SETTINGS" ]; then
    cat <<JSON > "$SETTINGS"
{
  "theme": "light",
  "sidebar": true,
  "modules": [true, true, true, true, true, true, true, true, true, true, true, true],
  "font_size": 12
}
JSON
fi

STAMP=$(date --iso-8601=seconds)
echo -e "ID: 25\\nZeit: $STAMP\\nBeschreibung: Globale Einstellungen, Update-Auto-Check, Module aktivierbar, barrierefrei, modern\\nDateien:\\n  - $GUIFILE\\n  - $SETTINGS" > creatoros/updater/meta/changes/change_25.txt
echo "Update 25 applied $STAMP" >> creatoros/updater/info-stand.txt
md5sum "$GUIFILE" "$SETTINGS" >> creatoros/updater/CHECKSUMS.txt

echo "✅ Update 25 erfolgreich abgeschlossen."
