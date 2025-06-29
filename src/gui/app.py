from PyQt5 import QtWidgets, QtCore
import importlib
import pkgutil
from pathlib import Path
import datetime

from auth.login import authenticate

settings = QtCore.QSettings("2025_BASIC", "app")

LOG_DIR = Path("logs")


def ensure_log_directory():
    """Create logging directory and default log files."""
    LOG_DIR.mkdir(exist_ok=True)
    for name in ["auto_repair.log", "debug_details.log"]:
        file_path = LOG_DIR / name
        if not file_path.exists():
            file_path.touch()
    return LOG_DIR


def get_setting(key: str, default=None):
    return settings.value(key, default)


def set_setting(key: str, value):
    settings.setValue(key, value)


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
    """Create a data folder for the given user along with standard subfolders."""
    user_dir = root / username
    user_dir.mkdir(parents=True, exist_ok=True)

    # automatically create some common subfolders
    for name in ["Dokumente", "Bilder"]:
        (user_dir / name).mkdir(exist_ok=True)

    return user_dir


def create_settings_tab():
    """Return a QWidget with debug and path options."""
    tab = QtWidgets.QWidget()
    layout = QtWidgets.QFormLayout(tab)

    debug_check = QtWidgets.QCheckBox()
    debug_check.setChecked(bool(get_setting("debug", False)))
    layout.addRow("Debug-Modus", debug_check)

    path_edit = QtWidgets.QLineEdit(get_setting("user_path", "users"))
    choose_btn = QtWidgets.QPushButton("Pfad wählen")

    def choose_path():
        directory = QtWidgets.QFileDialog.getExistingDirectory(tab, "Nutzerverzeichnis", path_edit.text())
        if directory:
            path_edit.setText(directory)

    choose_btn.clicked.connect(choose_path)
    path_row = QtWidgets.QHBoxLayout()
    path_row.addWidget(path_edit)
    path_row.addWidget(choose_btn)
    layout.addRow("Nutzerpfad", path_row)

    def update_settings():
        set_setting("debug", debug_check.isChecked())
        set_setting("user_path", path_edit.text())

    debug_check.toggled.connect(update_settings)
    path_edit.editingFinished.connect(update_settings)

    return tab


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
    user_root = Path(get_setting("user_path", "users"))
    ensure_user_folder(username, user_root)
    debug_enabled = bool(get_setting("debug", False))
    ensure_log_directory()
    if debug_enabled:
        print("Debug-Modus aktiviert")
        log_file = LOG_DIR / "debug_details.log"
        with log_file.open("a", encoding="utf-8") as fh:
            timestamp = datetime.datetime.now().isoformat()
            fh.write(f"{timestamp}: Debug-Modus aktiviert\n")

    window = QtWidgets.QMainWindow()
    window.setWindowTitle("2025_BASIC App")
    window.resize(800, 600)

    # Central area with tabs
    tabs = QtWidgets.QTabWidget()

    dashboard = QtWidgets.QWidget()
    center_layout = QtWidgets.QVBoxLayout(dashboard)
    center_label = QtWidgets.QLabel("Dashboard", alignment=QtCore.Qt.AlignCenter)
    center_layout.addWidget(center_label)
    tabs.addTab(dashboard, "Dashboard")

    tabs.addTab(create_settings_tab(), "Einstellungen")

    window.setCentralWidget(tabs)

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
