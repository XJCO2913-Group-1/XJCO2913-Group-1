from typing import Generator

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from pydantic import ValidationError
from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.core.config import settings
from app.core.security import verify_password
from app.models.user import User
from app.schemas.token import TokenPayload

oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{settings.API_V1_STR}/auth/login")


def get_db() -> Generator:
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()


def get_current_user(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)) -> User:
    """
    Validate token and return current user
    """
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        token_data = TokenPayload(**payload)
    except (JWTError, ValidationError):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Could not validate credentials",
        )
    
    # In a real implementation, you would fetch the user from the database
    # Example: user = db.query(User).filter(User.id == token_data.sub).first()
    # For now, we'll return a placeholder user
    user = User(id=1, email="user@example.com", is_active=True)
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return user


def authenticate_user(db: Session, email: str, password: str) -> User:
    """
    Verify username and password
    """
    # In a real implementation, you would fetch the user from the database
    # Example: user = db.query(User).filter(User.email == email).first()
    # For now, we'll return a placeholder user if credentials match
    if email == "user@example.com" and password == "password":
        return User(id=1, email=email, is_active=True)
    return None