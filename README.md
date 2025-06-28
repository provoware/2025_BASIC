# 2025_BASIC

This repository contains a minimal GUI demo project. The code is split into
three packages under `src/`:

- `gui` – Tkinter-based application window and plugin loader.
- `database` – SQLAlchemy setup for an SQLite database.
- `auth` – simple user management utilities.

Run the app with:

```bash
python main.py
```

## Further Suggestions for Beginners

- Explore how plugins are loaded in `src/gui/app.py` and try creating your own
  modules inside the `plugins/` directory.
- The current authentication logic uses the Werkzeug password utilities. For a
  real project, consider more advanced user management and proper error
  handling.
- Check out SQLAlchemy's documentation to learn how to create models and query
  data effectively.
