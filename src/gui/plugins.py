"""Simple plugin loader."""
from importlib import import_module
from pathlib import Path

PLUGIN_PATH = Path(__file__).parent / "plugins"


def load_plugins():
    modules = []
    if PLUGIN_PATH.exists():
        for file in PLUGIN_PATH.glob("*.py"):
            if file.name.startswith("_"):
                continue
            module_name = f"{__package__}.plugins.{file.stem}"
            modules.append(import_module(module_name))
    return modules
