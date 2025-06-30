from pathlib import Path
import shutil


def cleanup_directory(root: Path = Path(".")) -> None:
    """Remove __pycache__ folders under the given root."""
    for directory in root.rglob("__pycache__"):
        shutil.rmtree(directory, ignore_errors=True)
