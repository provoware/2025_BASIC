#!/usr/bin/env bash
set -euo pipefail
GUIFILE=creatoros/interface/steelcore_dashboard.py

cat <<'EOF' > "$GUIFILE"
# -*- coding: utf-8 -*-
import tkinter as tk
from tkinter import ttk

class SteelCoreDashboard(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Steel-Core Dashboard")
        self.geometry("1280x800")
        self.theme = "light"
        self.modules = []
        self.drag_data = {"widget": None, "x": 0, "y": 0}

        self.create_layout()

    def create_layout(self):
        self.header = ttk.Frame(self)
        self.header.pack(fill=tk.X)
        self.theme_button = ttk.Button(self.header, text="🌗 Theme", command=self.toggle_theme)
        self.theme_button.pack(side=tk.RIGHT, padx=5)
        ttk.Label(self.header, text="Steel-Core vX.Y", font=("Arial", 18, "bold")).pack(side=tk.LEFT, padx=10)

        self.main_frame = ttk.Frame(self)
        self.main_frame.pack(fill=tk.BOTH, expand=True)

        self.grid_area = ttk.Frame(self.main_frame)
        self.grid_area.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        for row in range(3):
            self.grid_area.rowconfigure(row, weight=1)
            for col in range(4):
                self.grid_area.columnconfigure(col, weight=1)
                f = ttk.Frame(self.grid_area, relief="raised", borderwidth=2)
                f.grid(row=row, column=col, sticky="nsew", padx=4, pady=4)
                label = tk.Label(f, text=f"Modul {row*4+col+1}", bg="#f0f0f0", relief="flat")
                label.pack(expand=True, fill=tk.BOTH)
                label.bind("<ButtonPress-1>", self.on_drag_start)
                label.bind("<B1-Motion>", self.on_drag_motion)
                label.bind("<ButtonRelease-1>", self.on_drag_release)
                self.modules.append(label)

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

if __name__ == "__main__":
    app = SteelCoreDashboard()
    app.mainloop()

EOF

STAMP=$(date --iso-8601=seconds)
echo -e "ID: 21\nZeit: $STAMP\nBeschreibung: Drag&Drop + Theme-Switcher\nDateien:\n  - $GUIFILE" > creatoros/updater/meta/changes/change_21.txt
echo "Update 21 applied $STAMP" >> creatoros/updater/info-stand.txt
md5sum "$GUIFILE" >> creatoros/updater/CHECKSUMS.txt

echo "✅ Update 21 erfolgreich abgeschlossen."
