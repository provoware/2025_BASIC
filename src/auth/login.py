from sqlalchemy.orm import Session
from werkzeug.security import check_password_hash, generate_password_hash
from ..database.models import User


def create_user(session: Session, username: str, password: str) -> User:
    user = User(username=username, password=generate_password_hash(password))
    session.add(user)
    session.commit()
    return user


def authenticate(session: Session, username: str, password: str) -> bool:
    user = session.query(User).filter_by(username=username).first()
    if not user:
        return False
    return check_password_hash(user.password, password)
