"""Main entry point for the 2025_BASIC application."""

import sys
from pathlib import Path

SRC_PATH = Path(__file__).resolve().parent / "src"
if str(SRC_PATH) not in sys.path:
    sys.path.insert(0, str(SRC_PATH))

from gui.app import run

if __name__ == "__main__":
    run()
