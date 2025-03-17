import pytest
from sqlalchemy.orm import Session
from app.models.user import User
from app.core.security import get_password_hash, verify_password

def test_create_user(db: Session):
    email = "test@example.com"
    password = "testpassword"
    hashed_password = get_password_hash(password)
    
    user = User(
        email=email,
        hashed_password=hashed_password,
        full_name="Test User",
        is_active=True
    )
    
    db.add(user)
    db.commit()
    db.refresh(user)
    
    assert user.email == email
    assert verify_password(password, user.hashed_password)
    assert user.is_active

def test_deactivate_user(db: Session):
    email = "test2@example.com"
    password = "testpassword"
    hashed_password = get_password_hash(password)
    
    user = User(
        email=email,
        hashed_password=hashed_password,
        full_name="Test User 2",
        is_active=True
    )
    
    db.add(user)
    db.commit()
    
    user.is_active = False
    db.commit()
    db.refresh(user)
    
    assert not user.is_active