from PyQt5 import QtWidgets, QtCore
import importlib
import pkgutil


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


def run():
    """Launch the main application window."""
    app = QtWidgets.QApplication([])
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
