import importlib
import pkgutil
import pathlib
from tkinter import Tk, Label


PLUGIN_DIR = pathlib.Path(__file__).resolve().parent.parent / "plugins"


def load_plugins():
    """Load plugins from the plugins directory and return a dict of modules."""
    plugins = {}
    if PLUGIN_DIR.exists():
        for _, name, _ in pkgutil.iter_modules([str(PLUGIN_DIR)]):
            module = importlib.import_module(f"plugins.{name}")
            plugins[name] = module
    return plugins


def run():
    """Launch the main GUI window and display loaded plugins."""
    plugins = load_plugins()
    root = Tk()
    root.title("Sample Application")
    info = "Loaded plugins: " + ", ".join(plugins.keys()) if plugins else "No plugins found"
    Label(root, text=info).pack(padx=20, pady=20)
    root.mainloop()

