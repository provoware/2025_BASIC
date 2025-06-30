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
