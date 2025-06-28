from PyQt6.QtWidgets import QApplication, QLabel, QWidget, QVBoxLayout
import sys

class MainWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Plugin GUI")
        layout = QVBoxLayout()
        layout.addWidget(QLabel("Hello from GUI"))
        self.setLayout(layout)


def launch():
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
