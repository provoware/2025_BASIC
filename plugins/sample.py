"""Simple demonstration plugin."""

from PyQt5 import QtWidgets


def register(window: QtWidgets.QMainWindow) -> None:
    """Register plugin actions with the main window."""
    action = QtWidgets.QAction("Sample", window)
    action.triggered.connect(
        lambda: QtWidgets.QMessageBox.information(window, "Sample", "Plugin geladen")
    )
    window.menuBar().addAction(action)
