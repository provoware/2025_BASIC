#!/usr/bin/env bash
set -euo pipefail
mkdir -p creatoros/interface creatoros/updater/meta/changes

DASH=creatoros/interface/steelcore_dashboard.py
WRAP=start_gui_dashboard.sh

# GUI-Datei
cat <<'EOF' > "$DASH"
# -*- coding: utf-8 -*-
import tkinter as tk
from tkinter import ttk

class SteelCoreDashboard(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Steel-Core Dashboard")
        self.geometry("1280x800")

        self.create_layout()

    def create_layout(self):
        self.header = ttk.Label(self, text="Steel-Core vX.Y", anchor="center", font=("Arial", 18, "bold"))
        self.header.pack(fill=tk.X)

        self.main_frame = ttk.Frame(self)
        self.main_frame.pack(fill=tk.BOTH, expand=True)

        self.left_sidebar = ttk.Frame(self.main_frame, width=100)
        self.left_sidebar.pack(side=tk.LEFT, fill=tk.Y)

        self.right_sidebar = ttk.Frame(self.main_frame, width=100)
        self.right_sidebar.pack(side=tk.RIGHT, fill=tk.Y)

        self.grid_area = ttk.Frame(self.main_frame)
        self.grid_area.pack(fill=tk.BOTH, expand=True)

        for row in range(3):
            self.grid_area.rowconfigure(row, weight=1)
            for col in range(4):
                self.grid_area.columnconfigure(col, weight=1)
                box = ttk.Label(self.grid_area, text=f"Module {row*4+col+1}", borderwidth=1, relief="solid", anchor="center")
                box.grid(row=row, column=col, sticky="nsew", padx=4, pady=4)

        self.footer = ttk.Frame(self)
        self.footer.pack(fill=tk.X)
        for i in range(4):
            label = ttk.Label(self.footer, text=f"F{i+1}", anchor="center")
            label.grid(row=0, column=i, sticky="ew")
            self.footer.columnconfigure(i, weight=1)

if __name__ == "__main__":
    app = SteelCoreDashboard()
    app.mainloop()
EOF

# Starter
cat <<'EOF' > "$WRAP"
#!/usr/bin/env bash
set -euo pipefail
python3 creatoros/interface/steelcore_dashboard.py
EOF
chmod +x "$WRAP"

STAMP=$(date --iso-8601=seconds)
echo -e "ID: 20\nZeit: $STAMP\nBeschreibung: GUI-Dashboard barrierefrei + modular\nDateien:\n  - $DASH\n  - $WRAP" > creatoros/updater/meta/changes/change_20.txt
echo "Update 20 applied $STAMP" >> creatoros/updater/info-stand.txt
md5sum "$DASH" "$WRAP" >> creatoros/updater/CHECKSUMS.txt

echo "✅ Update 20 erfolgreich abgeschlossen."
