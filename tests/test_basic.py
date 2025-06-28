import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

import types
import pytest


class DummyWindow:
    def setWindowTitle(self, title):
        self.title = title

    def resize(self, w, h):
        self.size = (w, h)

    def show(self):
        self.shown = True


class DummyApp:
    def __init__(self, *args, **kwargs):
        self.window = None

    def exec_(self):
        return 0


def setup_pyqt(monkeypatch):
    """Set up dummy PyQt5 modules so gui.app can be imported without PyQt5."""
    pyqt5 = types.ModuleType("PyQt5")
    qtwidgets = types.SimpleNamespace(
        QApplication=lambda *args, **kwargs: DummyApp(),
        QMainWindow=lambda *args, **kwargs: DummyWindow(),
    )
    pyqt5.QtWidgets = qtwidgets
    sys.modules["PyQt5"] = pyqt5
    sys.modules["PyQt5.QtWidgets"] = qtwidgets


def test_database_init(tmp_path, monkeypatch):
    from database import db

    monkeypatch.setattr(db, "DB_PATH", tmp_path / "test.db")
    db.init_db()
    conn = db.get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='users'"
    )
    assert cursor.fetchone() is not None
    conn.close()


def test_authenticate(tmp_path, monkeypatch):
    from database import db
    from auth import login

    monkeypatch.setattr(db, "DB_PATH", tmp_path / "test.db")
    db.init_db()
    conn = db.get_connection()
    conn.execute(
        "INSERT INTO users (username, password) VALUES (?, ?)",
        ("alice", login.hash_password("secret")),
    )
    conn.commit()
    conn.close()

    assert login.authenticate("alice", "secret")
    assert not login.authenticate("alice", "wrong")
    assert not login.authenticate("bob", "secret")


def test_run_gui(monkeypatch):
    setup_pyqt(monkeypatch)
    from gui import app

    result = app.run()
    assert result == 0
