# 2025_BASIC

This project provides a simple GUI application template with an SQLite database
and user authentication. The code is located under the `src/` directory. When
starting the app you will be asked to log in. On successful login a directory
`users/<name>` is created automatically for storing user files.

The main window presents a basic dashboard with collapsible sidebars on the left
and right. The structure is modular so that plugins placed in a `plugins/`
package can extend the interface.

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

## Tips for Beginners

1. **Create a virtual environment** to keep dependencies isolated:

   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Run the application** from the repository root with:

   ```bash
   python main.py
   ```

3. **Explore the code** in the `src/` directory to see how the GUI, database,
   and authentication pieces work together. Small changes, such as adding new
   menu items, are a great way to learn.

