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


## Getting Started for Beginners

If you are new to Python or this project, these steps will help you get up and running:

1. Install Python 3.12 or newer on your system.
2. Create a virtual environment with `python -m venv venv` and activate it (`source venv/bin/activate` on Linux/macOS or `venv\Scripts\activate` on Windows).
3. Install project dependencies by running `pip install -r requirements.txt`.
4. Start the application using `python main.py`.
5. For development mode with tests and auto-repair run `python dev_start.py`.
6. New users are stored in the `app.db` SQLite database inside the `users` table. You can manage them with any SQLite client or a small Python script.

The `logs/` directory is created automatically when running `dev_start.py` and contains troubleshooting information.
