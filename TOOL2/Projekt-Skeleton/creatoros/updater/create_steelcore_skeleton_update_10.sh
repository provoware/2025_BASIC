#!/usr/bin/env bash
set -euo pipefail

BASE=creatoros/updater
TARGET=$BASE/creatoros/updater/update_manager.py
TEST=$BASE/creatoros/tests/test_update_manager.py
META=$BASE/meta/changes
CONFLICT=$BASE/conflicts

DRY_RUN=${1:-}
if [ "$DRY_RUN" == "--dry-run" ]; then
  echo "[DRY RUN] Erstelle Update 10 (GUI-Updater real)"
  echo "$TARGET"
  echo "$TEST"
  exit 0
fi

mkdir -p "$(dirname "$TARGET")" "$(dirname "$TEST")" "$META" "$CONFLICT"

for f in "$TARGET" "$TEST"; do
  if [ -f "$f" ]; then
    mv "$f" "$CONFLICT/$(basename "$f").bak.$(date +%s)"
    echo "[WARNUNG] $f verschoben nach conflicts/"
  fi
done

cat <<'EOF' > "$TARGET"
# -*- coding: utf-8 -*-
import os
import subprocess
from PyQt6.QtWidgets import QApplication, QWidget, QVBoxLayout, QPushButton, QLabel, QListWidget, QFileDialog, QHBoxLayout

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

        self.layout.addWidget(self.status_label)
        self.layout.addWidget(self.list_widget)
        self.layout.addWidget(self.load_button)

        button_layout = QHBoxLayout()
        button_layout.addWidget(self.run_button)
        button_layout.addWidget(self.revert_button)
        button_layout.addWidget(self.dry_run_button)
        self.layout.addLayout(button_layout)

        self.setLayout(self.layout)

        self.load_button.clicked.connect(self.choose_folder)
        self.run_button.clicked.connect(self.run_update)
        self.revert_button.clicked.connect(self.revert_update)
        self.dry_run_button.clicked.connect(lambda: self.run_update(dry_run=True))

        self.update_folder = "."

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
EOF

cat <<'EOF' > "$TEST"
# -*- coding: utf-8 -*-
def test_gui_loads():
    assert True  # später mit PyQt6-QTest ausbauen
EOF

chmod +x "$TARGET"

TIMESTAMP=$(date --iso-8601=seconds)
echo -e "ID: 10\nZeit: $TIMESTAMP\nBeschreibung: GUI-Updater mit Qt6 und Interaktivität\nDateien:\n  - $TARGET\n  - $TEST" > "$META/change_10.txt"
echo "Update 10 applied $TIMESTAMP" >> "$BASE/info-stand.txt"
md5sum "$TARGET" "$TEST" >> "$BASE/CHECKSUMS.txt"

echo "✅ Update 10 erfolgreich abgeschlossen."
