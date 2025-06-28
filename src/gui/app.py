from PyQt6.QtWidgets import QApplication, QLabel, QVBoxLayout, QWidget
import importlib
import pkgutil
from pathlib import Path
import sys


class MainWindow(QWidget):
    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("Basic App")
        layout = QVBoxLayout()
        layout.addWidget(QLabel("Hello world!"))
        self.setLayout(layout)
        self.load_plugins()

    def load_plugins(self) -> None:
        plugins_path = Path(__file__).parent / "plugins"
        if not plugins_path.is_dir():
            return
        for _, name, _ in pkgutil.iter_modules([str(plugins_path)]):
            module = importlib.import_module(f"gui.plugins.{name}")
            if hasattr(module, "init"):
                module.init(self)


def run() -> None:
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
