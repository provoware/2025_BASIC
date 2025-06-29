from database import db
from auth import login


def setup_user(tmp_path):
    db.DB_PATH = tmp_path / "test.db"
    db.init_db()
    conn = db.get_connection()
    conn.execute(
        "INSERT INTO users (username, password) VALUES (?, ?)",
        ("alice", login.hash_password("secret")),
    )
    conn.commit()
    conn.close()


def test_authenticate_success(tmp_path):
    setup_user(tmp_path)
    assert login.authenticate("alice", "secret") is True


def test_authenticate_wrong_password(tmp_path):
    setup_user(tmp_path)
    assert login.authenticate("alice", "wrong") is False
