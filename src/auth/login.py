from getpass import getpass
from hashlib import sha256

from database.db import get_connection, init_db


def hash_password(password: str) -> str:
    return sha256(password.encode("utf-8")).hexdigest()


def authenticate(username: str, password: str) -> bool:
    init_db()
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT password FROM users WHERE username=?", (username,))
    row = cursor.fetchone()
    conn.close()
    if not row:
        return False
    stored_password = row[0]
    return stored_password == hash_password(password)


def prompt_login() -> bool:
    username = input("Username: ")
    password = getpass("Password: ")
    return authenticate(username, password)
