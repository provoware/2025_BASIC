# -*- coding: utf-8 -*-
import importlib.util
import os

PLUGIN_DIR = "creatoros/plugins"

def list_plugins():
    return [f for f in os.listdir(PLUGIN_DIR) if f.endswith(".py")]

def load_and_run_plugins():
    results = []
    for fname in list_plugins():
        path = os.path.join(PLUGIN_DIR, fname)
        spec = importlib.util.spec_from_file_location(fname.replace(".py", ""), path)
        if spec and spec.loader:
            try:
                module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(module)
                if hasattr(module, "main") and callable(module.main):
                    result = module.main()
                    results.append((fname, "OK", result))
                else:
                    results.append((fname, "FEHLER", "Keine main()-Funktion"))
            except Exception as e:
                results.append((fname, "FEHLER", str(e)))
    return results
