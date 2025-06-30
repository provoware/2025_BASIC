from pathlib import Path


def create_user_directory(username: str, root: Path = Path("users")) -> Path:
    """Create a directory for the given user and return the path."""
    user_dir = root / username
    user_dir.mkdir(parents=True, exist_ok=True)
    return user_dir
