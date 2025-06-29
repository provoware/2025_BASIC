from auth.login import hash_password


def test_hash_password_length():
    assert len(hash_password("example")) == 64
