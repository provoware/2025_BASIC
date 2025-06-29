from PyQt5 import QtCore, QtWidgets


def register(window: QtWidgets.QMainWindow) -> None:
    """Add a demo tab to the main window."""
    dock = QtWidgets.QDockWidget("Demo", window)
    label = QtWidgets.QLabel("Hello from plugin!", alignment=QtCore.Qt.AlignCenter)
    dock.setWidget(label)
    window.addDockWidget(QtCore.Qt.BottomDockWidgetArea, dock)
