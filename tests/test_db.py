import sqlite3
from database import db


def test_init_db_creates_users_table(tmp_path):
    db.DB_PATH = tmp_path / "test.db"
    db.init_db()
    assert db.DB_PATH.exists()

    conn = db.get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='users'"
    )
    row = cursor.fetchone()
    conn.close()
    assert row is not None
