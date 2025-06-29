import sys, os, sqlite3, pytest

# src-Pfad für Imports einfügen
SRC_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'src'))
sys.path.insert(0, SRC_DIR)

# In-Memory-DB für alle Tests aufsetzen
@pytest.fixture(autouse=True)
def in_memory_db(monkeypatch):
    conn = sqlite3.connect(":memory:")
    cursor = conn.cursor()
    cursor.execute("CREATE TABLE users (username TEXT PRIMARY KEY, password TEXT NOT NULL)")
    from auth.login import hash_password
    cursor.execute(
        "INSERT INTO users (username, password) VALUES (?, ?)",
        ("tester", hash_password("secret"))
    )
    conn.commit()

    # Patch auth.login direkt
    import auth.login as loginmod
    monkeypatch.setattr(loginmod, "get_connection", lambda: conn)
    monkeypatch.setattr(loginmod, "init_db", lambda: None)

    yield
    conn.close()
