from pathlib import Path
from src.cli import run_cli


def test_cli_create_user(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    result = run_cli(["create-user", "tester"])
    assert result == 0
    assert (tmp_path / "users" / "tester").is_dir()
