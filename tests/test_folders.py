from pathlib import Path

from utils.folders import create_user_directory


def test_create_user_directory(tmp_path: Path) -> None:
    user_dir = create_user_directory("tester", root=tmp_path)
    assert user_dir.exists()
    assert user_dir.is_dir()
    assert user_dir.name == "tester"
