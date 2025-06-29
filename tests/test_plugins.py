import pytest

pytest.importorskip("PyQt5")

from gui.app import load_plugins


def test_plugins_can_be_loaded():
    plugins = load_plugins()
    assert any(getattr(mod, "register", None) for mod in plugins)
