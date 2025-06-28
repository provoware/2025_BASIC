from PyQt5 import QtWidgets


def load(main_window: QtWidgets.QMainWindow):
    """Demo plugin that adds a simple menu item."""
    demo_action = QtWidgets.QAction("Demo", main_window)
    demo_action.triggered.connect(lambda: QtWidgets.QMessageBox.information(main_window, "Demo", "Demo plugin loaded"))
    menu = main_window.menuBar().addMenu("Demo")
    menu.addAction(demo_action)
