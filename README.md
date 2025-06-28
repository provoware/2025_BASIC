# 2025_BASIC

This project provides a simple GUI application template with an SQLite database and user authentication. The code is located under the `src/` directory.

## Packages

- **gui** – contains the main application window and a basic plugin loader using `importlib`.
- **database** – handles SQLite connections and initial schema creation.
- **auth** – simple user login utilities.

Run the application with:

```bash
python main.py
```

## Tests

PyTest is used for the small test suite located in the `tests/` folder.
Run the tests with:

```bash
pytest -q
```

