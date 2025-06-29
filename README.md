# 2025_BASIC

This project provides a simple GUI application template with an SQLite database
and user authentication. The code is located under the `src/` directory. When
starting the app you will be asked to log in. On successful login a directory
`users/<name>` is created automatically for storing user files. The folder now
includes default `Dokumente` and `Bilder` subdirectories so new users have a
basic structure in place.

The main window presents a basic dashboard with collapsible sidebars on the left
and right. An additional "Einstellungen" tab lets you enable a debug mode and
change the user folder path. The structure is modular so that plugins placed in
a `plugins/` package can extend the interface.

## Packages

- **gui** – contains the main application window and a basic plugin loader using `importlib`.
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

Plugin modules placed under `plugins/` are loaded automatically at startup. This
provides an easy way to extend the GUI without modifying existing code.

