# 2025_BASIC

This project provides a simple GUI application template with an SQLite database
and user authentication. The code is located under the `src/` directory. When
starting the app you will be asked to log in. On successful login a directory
`users/<name>` is created automatically for storing user files. The helper
function `create_user_directory` in `src/utils/folders.py` manages these
folders.

The main window presents a basic dashboard with collapsible sidebars on the left
and right. The structure is modular so that plugins placed in a `plugins/`
package can extend the interface.

## Packages

- **gui** – contains the main application window and a basic plugin loader using `importlib`.
- **database** – handles SQLite connections and initial schema creation.
- **auth** – simple user login utilities.

Development tasks are tracked in `info-todo.txt`.

A convenience CLI script `tool.py` bundles common actions.

Example usage:
```bash
python tool.py run
python tool.py create-user alice
python tool.py test
python tool.py list-plugins
python tool.py cleanup
```

Run the application with:

```bash
python main.py
```

For development with logging and automatic test execution run:

```bash
python dev_start.py
```

To run the tests, execute:

```bash
pytest -q
```
All tests are located under the `tests/` directory.

Plugin modules placed under `plugins/` are loaded automatically at startup. This
provides an easy way to extend the GUI without modifying existing code.

