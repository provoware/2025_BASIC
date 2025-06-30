# -*- coding: utf-8 -*-
import tempfile
import os
from creatoros.modules import plugin_manager

def test_valid_plugin_runs():
    with tempfile.TemporaryDirectory() as tmp:
        fname = os.path.join(tmp, "test_plugin.py")
        with open(fname, "w") as f:
            f.write("def main(): return 'Hallo'")
        os.makedirs("creatoros/plugins", exist_ok=True)
        os.replace(fname, "creatoros/plugins/test_plugin.py")
        results = plugin_manager.load_and_run_plugins()
        assert any("OK" in r for r in results)

def test_missing_main_fails():
    with tempfile.TemporaryDirectory() as tmp:
        fname = os.path.join(tmp, "broken_plugin.py")
        with open(fname, "w") as f:
            f.write("def not_main(): pass")
        os.makedirs("creatoros/plugins", exist_ok=True)
        os.replace(fname, "creatoros/plugins/broken_plugin.py")
        results = plugin_manager.load_and_run_plugins()
        assert any("FEHLER" in r and "main" in r[2] for r in results)
