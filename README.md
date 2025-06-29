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


## Updating the repository

To publish your changes on GitHub, follow these beginner-friendly steps:

1. Ensure all dependencies are installed: `pip install -r requirements.txt`.
2. Make your code changes and commit them locally with `git commit -m "feat: <your message>"`.
3. Pull the latest changes from GitHub: `git pull origin main`.
4. Push your branch to GitHub: `git push origin <branch-name>`.
5. On GitHub, open a Pull Request and wait for automated tests to finish.

After the Pull Request is merged, your project will be up to date online.
