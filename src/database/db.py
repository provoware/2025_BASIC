import sqlite3
from pathlib import Path

DATABASE_PATH = Path("app.db")


def get_connection():
    """Return a SQLite connection to the application database."""
    return sqlite3.connect(DATABASE_PATH)


def init_db():
    """Create tables if they don't exist."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
        )
        """
    )
    conn.commit()
    conn.close()
