"""SQLite connection and schema setup."""
from sqlalchemy import create_engine, text

_engine = None


def get_engine(db_url="sqlite:///app.db"):
    """Return a SQLAlchemy engine connected to the given SQLite DB."""
    global _engine
    if _engine is None:
        _engine = create_engine(db_url)
    return _engine


def initialize_schema():
    """Create default tables if they do not exist."""
    engine = get_engine()
    with engine.begin() as conn:
        conn.execute(
            text(
                "CREATE TABLE IF NOT EXISTS users "
                "(id INTEGER PRIMARY KEY, username TEXT UNIQUE, password TEXT)"
            )
        )

