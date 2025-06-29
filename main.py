"""Entry point for the 2025_BASIC application."""

import sys
from pathlib import Path

# Ensure the `src` directory is on the Python path so that packages like
# ``gui`` and ``auth`` can be imported when running ``python main.py`` from the
# repository root.
SRC_PATH = Path(__file__).resolve().parent / "src"
if SRC_PATH.exists():
    sys.path.insert(0, str(SRC_PATH))

from gui.app import run

if __name__ == "__main__":
    run()
