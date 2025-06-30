from __future__ import annotations
"""
Update-Manager – Platzhalter-GUI (PyQt6) für Steel-Core
▪ fragt bei jedem Start nach dem Ordner mit update_*.sh / re-update_*.sh
▪ Ampelstatus: 🟢 = angewendet, ➖ = offen
▪ Buttons:  Update anwenden  |  Rückgängig  |  Ordner wählen
"""
import sys, subprocess, pathlib, re, datetime
from PyQt6.QtWidgets import (
    QApplication, QWidget, QPushButton, QFileDialog, QListWidget,
    QVBoxLayout, QLabel, QTextEdit, QMessageBox, QHBoxLayout
)

ROOT      = pathlib.Path(__file__).resolve().parents[1]
INFO_FILE = ROOT / "info-stand.txt"
ID_RE     = re.compile(r"create_steelcore_skeleton_(re-)?update_(\d{2})\.sh$")

# -------- Hilfsfunktionen ----------------------------------------------------
def ask_dir(prompt: str) -> pathlib.Path | None:
    path = QFileDialog.getExistingDirectory(None, prompt, str(ROOT))
    return pathlib.Path(path) if path else None

def applied_set() -> set[str]:
    applied=set()
    if INFO_FILE.exists():
        for ln in INFO_FILE.read_text().splitlines():
            m=re.match(r"-  Update (\d{2}) applied", ln)
            if m: applied.add(m.group(1))
    return applied

# -------- GUI-Klasse ---------------------------------------------------------
class Manager(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Steel-Core • Update-Manager")
        self.resize(600, 430)

        self.choose_btn = QPushButton("Update-Ordner wählen …")
        self.choose_btn.clicked.connect(self.choose_dir)

        self.list   = QListWidget()
        self.log    = QTextEdit(); self.log.setReadOnly(True)
        self.status = QLabel()

        btn_apply  = QPushButton("Update anwenden")
        btn_revert = QPushButton("Rückgängig")
        btn_apply.clicked.connect(lambda: self.run_kind("update"))
        btn_revert.clicked.connect(lambda: self.run_kind("re-update"))

        hl = QHBoxLayout(); hl.addWidget(btn_apply); hl.addWidget(btn_revert)
        lay = QVBoxLayout(self)
        lay.addWidget(self.choose_btn); lay.addWidget(self.list)
        lay.addLayout(hl); lay.addWidget(self.status); lay.addWidget(self.log)

        self.update_dir: pathlib.Path | None = None
        self.choose_dir()   # direkt beim Start

    # ----- Ordnerwahl --------------------------------------------------------
    def choose_dir(self):
        self.update_dir = ask_dir("Ordner mit Update-Skripten wählen")
        self.refresh()

    # ----- Liste & Ampelstatus ----------------------------------------------
    def scripts(self, pattern:str):
        return sorted(self.update_dir.glob(pattern)) if self.update_dir else []

    def refresh(self):
        self.list.clear()
        if not self.update_dir:
            self.status.setText("Kein Ordner gewählt.")
            return
        applied = applied_set()
        for up in self.scripts("create_steelcore_skeleton_update_*.sh"):
            uid = ID_RE.search(up.name).group(2)
            pair = self.update_dir / f"create_steelcore_skeleton_re-update_{uid}.sh"
            flag = "🟢" if uid in applied else "➖"
            pairflag = "✓" if pair.exists() else "✖"
            self.list.addItem(f"{flag} {pairflag}  {uid}  {up.name}")
        self.status.setText(f"{len(applied)} / {self.list.count()} Updates angewendet")

    # ----- Ausführung --------------------------------------------------------
    def current_uid(self):
        it = self.list.currentItem()
        return it.text().split()[2] if it else None

    def run_kind(self, kind:str):
        if not self.update_dir: self.choose_dir(); return
        uid = self.current_uid()
        if not uid:
            QMessageBox.information(self, "Hinweis", "Bitte Update auswählen."); return
        script = self.update_dir / f"create_steelcore_skeleton_{kind}_{uid}.sh"
        if not script.exists():
            QMessageBox.warning(self, "Fehlt", f"{script.name} nicht gefunden"); return
        if script.stat().st_mode & 0o111 == 0:
            QMessageBox.warning(self, "Berechtigung", f"{script.name} ist nicht ausführbar"); return

        self.status.setText(f"{kind} {uid} läuft …")
        proc = subprocess.run(["bash", str(script)], capture_output=True, text=True)
        self.log.append(proc.stdout + proc.stderr)
        self.refresh()

# -------- Main --------------------------------------------------------------
if __name__ == "__main__":
    app = QApplication(sys.argv)
    Manager().show()
    sys.exit(app.exec())
