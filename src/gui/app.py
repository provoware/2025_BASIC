from PyQt5 import QtWidgets
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
    window.resize(400, 300)
    window.show()

    # Load plugins (if any)
    load_plugins()

    return app.exec_()
