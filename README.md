# 2025_BASIC

A starter project for simple desktop tools written in Python. It provides a minimal GUI scaffold with SQLite persistence and basic user login.

## Purpose and Usage

* **Goal:** Offer a lightweight template for data-driven desktop applications.
* **Quick start:** Install dependencies with `pip install -r requirements.txt` and run `python main.py`.
* **License:** Released under the MIT license (see `LICENSE` for details).

## Packages

- **gui** – contains the main application window and a basic plugin loader using `importlib`.
- **database** – handles SQLite connections and initial schema creation.
- **auth** – simple user login utilities.

Run the application with:

```bash
python main.py
```

## Tips for Beginners

- Experiment with the layout in `src/gui` to see how the interface changes.
- Use a visual SQLite tool to inspect the database file created by the app.
- Browse through the code comments to learn how the pieces fit together.

