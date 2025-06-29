import importlib
import pkgutil
from pathlib import Path

from PyQt5 import QtCore, QtWidgets

from auth.login import authenticate


def load_plugins(package_name="plugins"):
    """Load and return plugin modules from the given package."""
    plugins = []
    try:
        package = importlib.import_module(package_name)
    except ModuleNotFoundError:
        return plugins

    for _, modname, ispkg in pkgutil.iter_modules(package.__path__):
        if not ispkg:
            module = importlib.import_module(f"{package_name}.{modname}")
            plugins.append(module)
    return plugins


class LoginDialog(QtWidgets.QDialog):
    """Simple username/password dialog."""

    def __init__(self):
        super().__init__()
        self.setWindowTitle("Login")
        layout = QtWidgets.QFormLayout(self)

        self.user_edit = QtWidgets.QLineEdit()
        self.pass_edit = QtWidgets.QLineEdit()
        self.pass_edit.setEchoMode(QtWidgets.QLineEdit.Password)

        layout.addRow("Benutzername", self.user_edit)
        layout.addRow("Passwort", self.pass_edit)

        buttons = QtWidgets.QDialogButtonBox(
            QtWidgets.QDialogButtonBox.Ok | QtWidgets.QDialogButtonBox.Cancel
        )
        buttons.accepted.connect(self.accept)
        buttons.rejected.connect(self.reject)
        layout.addRow(buttons)

    def credentials(self):
        return self.user_edit.text(), self.pass_edit.text()


def ensure_user_folder(username: str, root: Path = Path("users")):
    """Create a data folder for the given user if it doesn't exist."""
    user_dir = root / username
    user_dir.mkdir(parents=True, exist_ok=True)
    return user_dir


def run():
    """Launch the main application window."""
    app = QtWidgets.QApplication([])

    # Login first
    login = LoginDialog()
    if login.exec_() != QtWidgets.QDialog.Accepted:
        return 0
    username, password = login.credentials()
    if not authenticate(username, password):
        QtWidgets.QMessageBox.warning(None, "Fehler", "Login fehlgeschlagen")
        return 0
    ensure_user_folder(username)

    window = QtWidgets.QMainWindow()
    window.setWindowTitle("2025_BASIC App")
    window.resize(800, 600)

    # Central dashboard widget
    dashboard = QtWidgets.QWidget()
    center_layout = QtWidgets.QVBoxLayout(dashboard)
    center_label = QtWidgets.QLabel("Dashboard", alignment=QtCore.Qt.AlignCenter)
    center_layout.addWidget(center_label)
    window.setCentralWidget(dashboard)

    # Left sidebar (dockable)
    left_dock = QtWidgets.QDockWidget("Links", window)
    left_contents = QtWidgets.QListWidget()
    left_contents.addItem("Option 1")
    left_contents.addItem("Option 2")
    left_dock.setWidget(left_contents)
    window.addDockWidget(QtCore.Qt.LeftDockWidgetArea, left_dock)

    # Right sidebar (dockable)
    right_dock = QtWidgets.QDockWidget("Rechts", window)
    right_contents = QtWidgets.QListWidget()
    right_contents.addItem("Info 1")
    right_contents.addItem("Info 2")
    right_dock.setWidget(right_contents)
    window.addDockWidget(QtCore.Qt.RightDockWidgetArea, right_dock)

    window.show()

    # Load plugins (if any)
    load_plugins()

    return app.exec_()
