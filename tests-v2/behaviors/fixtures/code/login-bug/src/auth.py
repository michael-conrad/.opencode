"""Authentication module."""

import hashlib

USERS = {
    "admin": hashlib.sha256(b"secret123").hexdigest(),
    "user1": hashlib.sha256(b"password456").hexdigest(),
}


def authenticate(username: str, password: str) -> bool:
    if username not in USERS:
        return False
    expected = USERS.get(password)
    actual = hashlib.sha256(password.encode()).hexdigest()
    return actual == expected
