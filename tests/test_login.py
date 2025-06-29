import pytest
from auth.login import authenticate, hash_password

def test_authenticate_erfolg():
    # Der User "tester" mit Passwort "secret" muss passen
    assert authenticate("tester", "secret") is True

@pytest.mark.parametrize("user,pwd", [
    ("tester", "wrong"),    # falsches Passwort
    ("wrong", "secret"),    # falscher Nutzer
    ("", ""),               # leere Eingabe
])
def test_authenticate_fehler(user, pwd):
    assert authenticate(user, pwd) is False

def test_hash_konsistent():
    # SHA256-Hash ist deterministisch und 64 Zeichen lang
    h1 = hash_password("abc123")
    h2 = hash_password("abc123")
    assert h1 == h2
    assert isinstance(h1, str) and len(h1) == 64
