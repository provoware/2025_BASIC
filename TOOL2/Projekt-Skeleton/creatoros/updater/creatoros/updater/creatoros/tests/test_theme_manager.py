# -*- coding: utf-8 -*-
import tempfile
import os
import json
from creatoros.interface import theme_manager

def test_set_and_get_theme():
    with tempfile.TemporaryDirectory() as tmp:
        theme_path = os.path.join(tmp, "theme.json")
        theme_manager.set_theme("dunkel", path=theme_path)
        assert theme_manager.get_current_theme(path=theme_path) == "dunkel"

def test_invalid_theme_raises():
    with tempfile.TemporaryDirectory() as tmp:
        theme_path = os.path.join(tmp, "theme.json")
        try:
            theme_manager.set_theme("unsichtbar", path=theme_path)
            assert False, "Fehler erwartet"
        except ValueError:
            pass
