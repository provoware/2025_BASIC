from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

ENGINE = create_engine("sqlite:///app.db", echo=False)
SessionLocal = sessionmaker(bind=ENGINE)
Base = declarative_base()


def init_db() -> None:
    """Create database tables."""
    Base.metadata.create_all(ENGINE)
