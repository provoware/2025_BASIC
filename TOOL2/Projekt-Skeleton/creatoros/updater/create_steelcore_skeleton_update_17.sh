#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
DASH=creatoros/interface/status_dashboard.py
WRAPPER=start_dashboard.sh
GUI=creatoros/updater/creatoros/updater/update_manager.py
META=$BASE/meta/changes
CONFLICT=$BASE/conflicts

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 17 (Dashboard-GUI integriert)"
  echo "$GUI"
  echo "$DASH"
  echo "$WRAPPER"
  exit 0
fi

mkdir -p "$(dirname "$DASH")" "$META" "$CONFLICT"

if [ -f "$GUI" ]; then
  mv "$GUI" "$CONFLICT/update_manager.py.bak.$(date +%s)"
  echo "[WARNUNG] $GUI verschoben"
fi

cat <<'EOF' > "$DASH"
# -*- coding: utf-8 -*-
import os
import subprocess
from PyQt6.QtWidgets import QWidget, QVBoxLayout, QLabel, QPushButton, QListWidget, QApplication
from PyQt6.QtGui import QColor

class StatusDashboard(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Projektstatus – Übersicht")
        self.resize(500, 400)
        layout = QVBoxLayout()

        self.label = QLabel("Analyse-Status der Projektstruktur:")
        layout.addWidget(self.label)

        self.list = QListWidget()
        layout.addWidget(self.list)

        self.refresh_button = QPushButton("🔄 Aktualisieren")
        self.cleanup_button = QPushButton("🧹 Cleanup starten")
        layout.addWidget(self.refresh_button)
        layout.addWidget(self.cleanup_button)

        self.setLayout(layout)
        self.refresh_button.clicked.connect(self.run_analysis)
        self.cleanup_button.clicked.connect(self.run_cleanup)

        self.run_analysis()

    def run_analysis(self):
        self.list.clear()
        updates = [f for f in os.listdir("creatoros/updater") if f.startswith("create_steelcore_skeleton_update_") and f.endswith(".sh")]
        info_path = "creatoros/updater/info-stand.txt"
        applied = set()
        if os.path.exists(info_path):
            with open(info_path) as f:
                for line in f:
                    if line.startswith("Update"):
                        applied.add(line.split()[1])
        for u in sorted(updates):
            uid = u.split("_")[-1].replace(".sh", "")
            status = "✅" if uid in applied else "⚠️"
            self.list.addItem(f"{status} Update {uid}")

        # Platzhalter
        for root, dirs, files in os.walk("creatoros"):
            for f in files:
                if "__todo." in f:
                    self.list.addItem(f"❌ Platzhalter: {os.path.join(root, f)}")

    def run_cleanup(self):
        subprocess.run(["bash", "start_cleanup.sh"])

if __name__ == "__main__":
    app = QApplication([])
    gui = StatusDashboard()
    gui.show()
    app.exec()
EOF

cat <<'EOF' > "$WRAPPER"
#!/usr/bin/env bash
set -euo pipefail
python3 creatoros/interface/status_dashboard.py
EOF

cat <<'EOF' > "$GUI"
# -*- coding: utf-8 -*-
import os
import subprocess
from PyQt6.QtWidgets import QApplication, QWidget, QVBoxLayout, QPushButton, QLabel, QListWidget, QFileDialog, QHBoxLayout
from PyQt6.QtGui import QPalette, QColor
from creatoros.interface import theme_manager

class UpdateManager(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Steel-Core Updater")
        self.layout = QVBoxLayout()
        self.status_label = QLabel("Status: Initialisierung...")
        self.list_widget = QListWidget()
        self.load_button = QPushButton("Update-Ordner wählen")
        self.run_button = QPushButton("Anwenden")
        self.revert_button = QPushButton("Revertieren")
        self.dry_run_button = QPushButton("Dry-Run")

        self.theme_buttons = {
            "hell": QPushButton("☀️ Hell"),
            "dunkel": QPushButton("🌙 Dunkel"),
            "barrierefrei": QPushButton("🔍 Barrierefrei")
        }

        self.layout.addWidget(self.status_label)
        self.layout.addWidget(self.list_widget)
        self.layout.addWidget(self.load_button)

        button_layout = QHBoxLayout()
        button_layout.addWidget(self.run_button)
        button_layout.addWidget(self.revert_button)
        button_layout.addWidget(self.dry_run_button)
        self.layout.addLayout(button_layout)

        theme_layout = QHBoxLayout()
        for k, btn in self.theme_buttons.items():
            btn.clicked.connect(lambda _, t=k: self.apply_theme(t))
            theme_layout.addWidget(btn)
        self.layout.addLayout(theme_layout)

        self.setLayout(self.layout)

        self.load_button.clicked.connect(self.choose_folder)
        self.run_button.clicked.connect(self.run_update)
        self.revert_button.clicked.connect(self.revert_update)
        self.dry_run_button.clicked.connect(lambda: self.run_update(dry_run=True))

        self.update_folder = "."
        self.apply_theme(theme_manager.get_current_theme())

    def apply_theme(self, name):
        theme_manager.set_theme(name)
        pal = self.palette()
        if name == "hell":
            pal.setColor(QPalette.ColorRole.Window, QColor("white"))
            pal.setColor(QPalette.ColorRole.WindowText, QColor("black"))
            self.setPalette(pal)
            self.setStyleSheet("font-size: 12pt;")
        elif name == "dunkel":
            pal.setColor(QPalette.ColorRole.Window, QColor("#2d2d2d"))
            pal.setColor(QPalette.ColorRole.WindowText, QColor("white"))
            self.setPalette(pal)
            self.setStyleSheet("font-size: 12pt;")
        elif name == "barrierefrei":
            pal.setColor(QPalette.ColorRole.Window, QColor("white"))
            pal.setColor(QPalette.ColorRole.WindowText, QColor("black"))
            self.setPalette(pal)
            self.setStyleSheet("font-size: 16pt;")

    def choose_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "Update-Ordner wählen")
        if folder:
            self.update_folder = folder
            self.scan_updates()

    def scan_updates(self):
        self.list_widget.clear()
        info_path = os.path.join(self.update_folder, "info-stand.txt")
        applied = []
        if os.path.isfile(info_path):
            with open(info_path) as f:
                applied = [line.strip().split()[1] for line in f if line.startswith("Update")]
        for file in sorted(os.listdir(self.update_folder)):
            if file.startswith("create_steelcore_skeleton_update_") and file.endswith(".sh"):
                uid = file.split("_")[-1].replace(".sh", "")
                status = "✅" if uid in applied else "🟡"
                self.list_widget.addItem(f"{status} {file}")

    def run_update(self, dry_run=False):
        item = self.list_widget.currentItem()
        if item:
            script = item.text().split()[-1]
            path = os.path.join(self.update_folder, script)
            cmd = ["bash", path]
            if dry_run:
                cmd.append("--dry-run")
            subprocess.run(cmd)

    def revert_update(self):
        item = self.list_widget.currentItem()
        if item:
            script = item.text().split()[-1].replace("update", "re-update")
            path = os.path.join(self.update_folder, script)
            subprocess.run(["bash", path])

if __name__ == "__main__":
    app = QApplication([])
    window = UpdateManager()
    window.resize(600, 400)
    window.show()
    app.exec()


        self.status_button = QPushButton("📊 Status")
        self.status_button.clicked.connect(self.open_dashboard)
        self.layout.addWidget(self.status_button)

    def open_dashboard(self):
        subprocess.Popen(["python3", "creatoros/interface/status_dashboard.py"])
EOF

chmod +x "$WRAPPER"

TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 17\nZeit: $TIMESTAMP\nBeschreibung: Status-Dashboard-GUI integriert\nDateien:\n  - $GUI\n  - $DASH\n  - $WRAPPER" > "$META/change_17.txt"
echo "Update 17 applied $TIMESTAMP" >> "$BASE/info-stand.txt"
md5sum "$GUI" "$DASH" "$WRAPPER" >> "$BASE/CHECKSUMS.txt"

echo "✅ Update 17 erfolgreich abgeschlossen."
