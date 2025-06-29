"""Example plugin that adds an item to the left sidebar."""
from PyQt5 import QtWidgets


def init(app_window):
    """Simple hook that adds an item to the left dock list."""
    for dock in app_window.findChildren(QtWidgets.QDockWidget):
        if dock.windowTitle() == "Links":
            list_widget = dock.widget()
            list_widget.addItem("Example Plugin")
            break

