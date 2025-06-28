import importlib
import pkgutil
from pathlib import Path
import tkinter as tk
import pluggy


class GUIPluginSpec:
    def start(self, app: tk.Tk) -> None:
        """Optional hook called after plugins are loaded."""


class Application(tk.Tk):
    """Main application window with basic plugin loader."""

    def __init__(self, plugins_path: str | None = None):
        super().__init__()
        self.title("Demo App")
        self.geometry("300x200")
        self.plugins_path = Path(plugins_path or "plugins")
        self.plugin_manager = pluggy.PluginManager("guiapp")
        self.plugin_manager.add_hookspecs(GUIPluginSpec)
        self._load_plugins()
        self.plugin_manager.hook.start(app=self)

    def _load_plugins(self) -> None:
        """Load plugins as Python modules from the plugins directory."""
        if not self.plugins_path.exists():
            return
        for module_info in pkgutil.iter_modules([str(self.plugins_path)]):
            module_name = module_info.name
            try:
                mod = importlib.import_module(f"plugins.{module_name}")
                self.plugin_manager.register(mod)
            except Exception as exc:  # pragma: no cover - simple demo
                print(f"Failed to load plugin {module_name}: {exc}")
