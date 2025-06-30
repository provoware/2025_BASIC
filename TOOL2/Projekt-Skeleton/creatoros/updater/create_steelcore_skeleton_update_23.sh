#!/usr/bin/env bash
set -euo pipefail
GUIFILE=creatoros/interface/steelcore_dashboard.py

cat <<'EOF' > "$GUIFILE"
# -*- coding: utf-8 -*-
import tkinter as tk
from tkinter import ttk, messagebox
import json, os, datetime, traceback

STATE_FILE = "creatoros/interface/.grid_state.json"
LOG_FILE = "creatoros/interface/dashboard.log"

class Logger:
    def __init__(self, textbox):
        self.textbox = textbox

    def log(self, msg):
        timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        full_msg = f"[{timestamp}] {msg}"
        self.textbox.insert(tk.END, full_msg + '\n')
        self.textbox.see(tk.END)
        with open(LOG_FILE, "a") as f:
            f.write(full_msg + '\n')

class SteelCoreDashboard(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Steel-Core Dashboard")
        self.geometry("1280x800")
        self.theme = "light"
        self.drag_data = {"widget": None, "x": 0, "y": 0}
        self.modules = []
        self.logger = None

        try:
            self.setup_ui()
        except Exception as e:
            self.fatal_error("Fehler beim Start", e)

    def setup_ui(self):
        self.create_header()
        self.create_main()
        self.create_footer()
        self.configure_theme()
        self.load_positions()

    def create_header(self):
        self.header = ttk.Frame(self)
        self.header.pack(fill=tk.X)
        ttk.Label(self.header, text="Steel-Core Dashboard", font=("Arial", 16)).pack(side=tk.LEFT, padx=10)
        ttk.Button(self.header, text="💾 Speichern", command=self.save_positions).pack(side=tk.RIGHT)
        ttk.Button(self.header, text="🔄 Theme", command=self.toggle_theme).pack(side=tk.RIGHT)

    def create_main(self):
        main_frame = ttk.Frame(self)
        main_frame.pack(fill=tk.BOTH, expand=True)
        self.grid_area = ttk.Frame(main_frame)
        self.grid_area.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=10, pady=10)

        for i in range(12):
            mod = tk.Label(self.grid_area, text=f"Modul {i+1}", bg="#f0f0f0", relief="raised", bd=1)
            mod.place(x=20+(i%4)*300, y=20+(i//4)*200, width=280, height=180)
            mod.bind("<ButtonPress-1>", self.on_drag_start)
            mod.bind("<B1-Motion>", self.on_drag_motion)
            mod.bind("<ButtonRelease-1>", self.on_drag_release)
            self.modules.append(mod)

        log_frame = ttk.Frame(main_frame, relief="sunken")
        log_frame.pack(side=tk.RIGHT, fill=tk.Y, padx=10)
        ttk.Label(log_frame, text="📋 Log-Ausgabe:").pack(anchor="w")
        self.log_box = tk.Text(log_frame, width=40, height=30)
        self.log_box.pack(fill=tk.BOTH, expand=True)
        self.logger = Logger(self.log_box)
        self.logger.log("GUI erfolgreich gestartet.")

    def create_footer(self):
        footer = ttk.Frame(self)
        footer.pack(fill=tk.X)
        for i in range(4):
            ttk.Label(footer, text=f"F{i+1}").grid(row=0, column=i, sticky="ew")
            footer.columnconfigure(i, weight=1)

    def toggle_theme(self):
        self.theme = "dark" if self.theme == "light" else "light"
        self.configure_theme()
        self.logger.log(f"Theme gewechselt zu: {self.theme}")

    def configure_theme(self):
        bg = "#222" if self.theme == "dark" else "#fff"
        fg = "#eee" if self.theme == "dark" else "#000"
        for widget in self.modules:
            widget.config(bg=bg, fg=fg)

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

    def fatal_error(self, msg, err):
        traceback.print_exc()
        messagebox.showerror("Fehler", f"{msg}: {err}")
        self.logger and self.logger.log(f"❌ {msg}: {err}")
        self.destroy()

if __name__ == "__main__":
    app = SteelCoreDashboard()
    app.mainloop()

EOF

STAMP=$(date --iso-8601=seconds)
echo -e "ID: 23\nZeit: $STAMP\nBeschreibung: Strukturierte GUI mit Logging & Fehlertoleranz\nDateien:\n  - $GUIFILE" > creatoros/updater/meta/changes/change_23.txt
echo "Update 23 applied $STAMP" >> creatoros/updater/info-stand.txt
md5sum "$GUIFILE" >> creatoros/updater/CHECKSUMS.txt

echo "✅ Update 23 erfolgreich abgeschlossen."
