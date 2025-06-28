from __future__ import annotations

import sqlite3
from pathlib import Path

DB_PATH = Path("app.db")


def get_connection() -> sqlite3.Connection:
    return sqlite3.connect(DB_PATH)


def initialize_schema() -> None:
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
