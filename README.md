# 2025_BASIC

This project provides a simple GUI application template with an SQLite database and user authentication. The code lives under the `src/` directory. When starting the app you will be asked to log in. On successful login a directory `users/<name>` is created automatically for storing user files.

The main window presents a basic dashboard with collapsible sidebars on the left and right. The structure is modular so that plugins placed in a `plugins/` package can extend the interface.

## Setup
Install the dependencies once with:

```bash
pip install -r requirements.txt
```

## Packages
- **gui** – main application window and plugin loader
- **database** – SQLite connection and initial schema
- **auth** – user login utilities

Development tasks are tracked in `info-todo.txt`.

Run the application with:

```bash
python main.py
```

To run tests (once they are added), execute:

```bash
pytest -q
```

Plugin modules placed under `plugins/` are loaded automatically at startup. This provides an easy way to extend the GUI without modifying existing code.

## Änderungen auf GitHub hochladen
Neue Features oder Dokumentationsanpassungen lassen sich mit Git nutzen:

```bash
git add .
# Commit-Nachricht im Format "feat: beschreibung" oder "docs: ..."
git commit -m "docs: erweitere README"
# Remote-URL einmalig hinterlegen
# git remote add origin https://github.com/<name>/2025_BASIC.git
# und anschließend pushen

git push origin main
```

Damit wird der aktuelle Stand im eigenen GitHub-Repository veröffentlicht.

