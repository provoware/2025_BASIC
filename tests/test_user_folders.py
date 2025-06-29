from pathlib import Path

from gui.app import ensure_user_folder


def test_standard_subfolders(tmp_path):
    base = tmp_path / "users"
    path = ensure_user_folder("alice", root=base)
    assert (path / "Dokumente").exists()
    assert (path / "Bilder").exists()
    assert (path / "Projekte").exists()
