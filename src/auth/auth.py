from __future__ import annotations

from typing import Optional

from database.db import get_connection


def authenticate(username: str, password: str) -> bool:
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT id FROM users WHERE username = ? AND password = ?",
        (username, password),
    )
    row: Optional[tuple] = cursor.fetchone()
    conn.close()
    return row is not None
