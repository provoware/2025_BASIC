import logging
import subprocess
from pathlib import Path

from database.db import init_db
from gui.app import run

LOG_DIR = Path("logs")
LOG_DIR.mkdir(exist_ok=True)
logging.basicConfig(
    filename=LOG_DIR / "dev.log",
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)


def run_tests() -> bool:
    """Run test suite and return True if successful."""
    try:
        result = subprocess.run(["pytest", "-q"], check=False, capture_output=True)
        logging.info(result.stdout.decode())
        if result.returncode != 0:
            logging.error("Tests failed")
            return False
        return True
    except Exception as exc:  # pragma: no cover - best effort logging
        logging.exception("Running tests failed: %s", exc)
        return False


def auto_repair() -> None:
    """Simple self-healing placeholder."""
    db_file = Path("app.db")
    if not db_file.exists():
        logging.warning("Database missing. Reinitializing.")
        init_db()


if __name__ == "__main__":
    tests_ok = run_tests()
    if not tests_ok:
        print("Tests failed. See logs/dev.log for details.")
    auto_repair()
    try:
        run()
    except Exception as exc:  # pragma: no cover - guard GUI startup
        logging.exception("Application crashed: %s", exc)
        print("Application crashed. Check logs/dev.log.")
