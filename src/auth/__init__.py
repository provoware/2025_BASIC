from ..database import get_connection


def create_user(username: str, password: str) -> bool:
    """Create a new user. Returns True on success, False if user exists."""
    conn = get_connection()
    try:
        conn.execute(
            "INSERT INTO users (username, password) VALUES (?, ?)",
            (username, password),
        )
        conn.commit()
        return True
    except Exception:
        # Likely integrity error for duplicate username
        return False
    finally:
        conn.close()


def login(username: str, password: str) -> bool:
    """Return True if username/password match an existing user."""
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        "SELECT id FROM users WHERE username=? AND password=?",
        (username, password),
    )
    row = cur.fetchone()
    conn.close()
    return row is not None

