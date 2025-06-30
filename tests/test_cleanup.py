from utils.cleanup import cleanup_directory
from pathlib import Path


def test_cleanup_directory(tmp_path: Path) -> None:
    pycache = tmp_path / "package" / "__pycache__"
    pycache.mkdir(parents=True)
    (pycache / "dummy.pyc").touch()
    cleanup_directory(tmp_path)
    assert not pycache.exists()
