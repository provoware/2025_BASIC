#!/usr/bin/env bash
set -euo pipefail
GUIFILE=creatoros/interface/steelcore_dashboard.py

cat <<'EOF' > "$GUIFILE"
# -*- coding: utf-8 -*-
import tkinter as tk
from tkinter import ttk
import json
import os

STATE_FILE = "creatoros/interface/.grid_state.json"

class Tooltip:
    def __init__(self, widget, text):
        self.widget = widget
        self.text = text
        self.tip = None
        widget.bind("<Enter>", self.show)
        widget.bind("<Leave>", self.hide)

    def show(self, event=None):
        if self.tip or not self.text:
            return
        x, y, _, _ = self.widget.bbox("insert")
        x += self.widget.winfo_rootx() + 25
        y += self.widget.winfo_rooty() + 20
        self.tip = tw = tk.Toplevel(self.widget)
        tw.wm_overrideredirect(True)
        tw.wm_geometry(f"+{x}+{y}")
        label = tk.Label(tw, text=self.text, background="yellow", relief="solid", borderwidth=1)
        label.pack()

    def hide(self, event=None):
        if self.tip:
            self.tip.destroy()
            self.tip = None

class SteelCoreDashboard(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Steel-Core Dashboard")
        self.geometry("1280x800")
        self.theme = "light"
        self.modules = []
        self.drag_data = {"widget": None, "x": 0, "y": 0}

        self.create_layout()
        self.load_positions()

    def create_layout(self):
        self.header = ttk.Frame(self)
        self.header.pack(fill=tk.X)
        self.theme_button = ttk.Button(self.header, text="🌗 Theme", command=self.toggle_theme)
        self.theme_button.pack(side=tk.RIGHT, padx=5)
        ttk.Button(self.header, text="💾 Save", command=self.save_positions).pack(side=tk.RIGHT, padx=5)
        ttk.Label(self.header, text="Steel-Core vX.Y", font=("Arial", 18, "bold")).pack(side=tk.LEFT, padx=10)

        self.main_frame = ttk.Frame(self)
        self.main_frame.pack(fill=tk.BOTH, expand=True)

        self.grid_area = ttk.Frame(self.main_frame)
        self.grid_area.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        for i in range(12):
            lbl = tk.Label(self.grid_area, text=f"Modul {i+1}", bg="#f0f0f0", relief="flat", bd=1)
            lbl.place(x=20 + (i % 4) * 300, y=20 + (i // 4) * 200, width=280, height=180)
            lbl.bind("<ButtonPress-1>", self.on_drag_start)
            lbl.bind("<B1-Motion>", self.on_drag_motion)
            lbl.bind("<ButtonRelease-1>", self.on_drag_release)
            Tooltip(lbl, f"Dies ist Modul {i+1}")
            self.modules.append(lbl)

        self.footer = ttk.Frame(self)
        self.footer.pack(fill=tk.X)
        for i in range(4):
            label = ttk.Label(self.footer, text=f"F{i+1}")
            label.grid(row=0, column=i, sticky="ew")
            self.footer.columnconfigure(i, weight=1)

        self.configure_theme()

    def toggle_theme(self):
        self.theme = "dark" if self.theme == "light" else "light"
        self.configure_theme()

    def configure_theme(self):
        bg = "#222" if self.theme == "dark" else "#fff"
        fg = "#eee" if self.theme == "dark" else "#000"
        for widget in self.modules:
            widget.config(bg=bg, fg=fg)

    def on_drag_start(self, event):
        widget = event.widget
        self.drag_data["widget"] = widget
        self.drag_data["x"] = event.x
        self.drag_data["y"] = event.y

    def on_drag_motion(self, event):
        widget = self.drag_data["widget"]
        if widget:
            x = widget.winfo_x() - self.drag_data["x"] + event.x
            y = widget.winfo_y() - self.drag_data["y"] + event.y
            widget.place(x=x, y=y)

    def on_drag_release(self, event):
        self.drag_data["widget"] = None

    def save_positions(self):
        state = [{"x": m.winfo_x(), "y": m.winfo_y(), "text": m.cget("text")} for m in self.modules]
        with open(STATE_FILE, "w") as f:
            json.dump(state, f)
        print("📝 Positionen gespeichert.")

    def load_positions(self):
        if os.path.exists(STATE_FILE):
            try:
                with open(STATE_FILE, "r") as f:
                    state = json.load(f)
                for widget, saved in zip(self.modules, state):
                    widget.place(x=saved["x"], y=saved["y"])
            except Exception as e:
                print("⚠️ Fehler beim Laden des Layouts:", e)

if __name__ == "__main__":
    app = SteelCoreDashboard()
    app.mainloop()

EOF

STAMP=$(date --iso-8601=seconds)
echo -e "ID: 22\nZeit: $STAMP\nBeschreibung: Tooltips + Positionsspeicherung\nDateien:\n  - $GUIFILE" > creatoros/updater/meta/changes/change_22.txt
echo "Update 22 applied $STAMP" >> creatoros/updater/info-stand.txt
md5sum "$GUIFILE" >> creatoros/updater/CHECKSUMS.txt

echo "✅ Update 22 erfolgreich abgeschlossen."
