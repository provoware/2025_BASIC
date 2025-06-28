# 2025_BASIC

This project provides a simple GUI application template with an SQLite
database and a username/password login system. The code resides under the
`src/` directory. When starting the app you will be asked to log in. On
successful login a directory `users/<name>` is created automatically for
storing user files.

The main window presents a basic dashboard with collapsible sidebars on the left
and right. The structure is modular so that plugins placed in a `plugins/`
package can extend the interface.

## Packages

- **gui** – contains the PyQt5 application window and a basic plugin loader
  using `importlib`.
- **database** – handles SQLite connections and initial schema creation.
- **auth** – simple user login utilities.

Development tasks are tracked in `info-todo.txt`.

Run the application with:

```bash
python main.py
```

To run tests (once they are added), execute:

```bash
pytest -q
```

Plugin modules placed under `plugins/` are loaded automatically at startup.
This repository includes a small example under `plugins/demo_plugin` that
adds a demo menu entry. Use it as a starting point for your own extensions.

