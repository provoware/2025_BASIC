"""Simple user-login functionality."""
from getpass import getpass


USERS = {"admin": "password"}


def authenticate(username: str, password: str) -> bool:
    """Return True if credentials match."""
    return USERS.get(username) == password


def prompt_login() -> bool:
    username = input("Username: ")
    password = getpass("Password: ")
    return authenticate(username, password)

