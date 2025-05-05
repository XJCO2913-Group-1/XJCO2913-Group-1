import pytest
from sqlalchemy.orm import Session
from fastapi import HTTPException

from app.crud.user import user
from app.schemas.user import UserCreate, UserUpdate


def test_create_user(db: Session):
    user_in = UserCreate(
        email="test@example.com", password="testpassword", name="Test User"
    )
    db_user = user.create(db=db, obj_in=user_in)
    assert db_user.email == user_in.email
    assert db_user.name == user_in.name
    assert hasattr(db_user, "hashed_password")
    assert db_user.hashed_password != user_in.password


def test_create_user_duplicate_email(db: Session):
    user_in = UserCreate(
        email="test2@example.com", password="testpassword", name="Test User 2"
    )
    user.create(db=db, obj_in=user_in)

    # Try to create user with same email
    with pytest.raises(HTTPException) as exc_info:
        user.create(db=db, obj_in=user_in)
    assert exc_info.value.status_code == 400


def test_get_user(db: Session):
    user_in = UserCreate(
        email="test3@example.com", password="testpassword", name="Test User 3"
    )
    created_user = user.create(db=db, obj_in=user_in)

    fetched_user = user.get(db=db, id=created_user.id)
    assert fetched_user
    assert fetched_user.email == user_in.email
    assert fetched_user.name == user_in.name


def test_get_user_by_email(db: Session):
    user_in = UserCreate(
        email="test4@example.com", password="testpassword", name="Test User 4"
    )
    user.create(db=db, obj_in=user_in)

    fetched_user = user.get_by_email(db=db, email=user_in.email)
    assert fetched_user
    assert fetched_user.email == user_in.email
    assert fetched_user.name == user_in.name


def test_update_user(db: Session):
    # Create a user first
    user_in = UserCreate(
        email="test5@example.com", password="testpassword", name="Test User 5"
    )
    db_user = user.create(db=db, obj_in=user_in)

    # Update the user
    user_update = UserUpdate(name="Updated Name")
    updated_user = user.update(db=db, db_obj=db_user, obj_in=user_update)

    assert updated_user.name == "Updated Name"
    assert updated_user.email == user_in.email


def test_update_user_password(db: Session):
    # Create a user first
    user_in = UserCreate(
        email="test6@example.com", password="testpassword", name="Test User 6"
    )
    db_user = user.create(db=db, obj_in=user_in)
    original_password_hash = db_user.hashed_password

    # Update the password
    user_update = UserUpdate(password="newpassword")
    updated_user = user.update(db=db, db_obj=db_user, obj_in=user_update)

    assert updated_user.hashed_password != original_password_hash


def test_authenticate_user(db: Session):
    user_in = UserCreate(
        email="test7@example.com", password="testpassword", name="Test User 7"
    )
    user.create(db=db, obj_in=user_in)

    # Test successful authentication
    authenticated_user = user.authenticate(
        db=db, email=user_in.email, password=user_in.password
    )
    assert authenticated_user
    assert authenticated_user.email == user_in.email

    # Test failed authentication with wrong password
    wrong_auth_user = user.authenticate(
        db=db, email=user_in.email, password="wrongpassword"
    )
    assert wrong_auth_user is None

    # Test failed authentication with wrong email
    wrong_auth_user = user.authenticate(
        db=db, email="wrong@example.com", password=user_in.password
    )
    assert wrong_auth_user is None


def test_delete_user(db: Session):
    user_in = UserCreate(
        email="test8@example.com", password="testpassword", name="Test User 8"
    )
    db_user = user.create(db=db, obj_in=user_in)

    user.remove(db=db, id=db_user.id)
    deleted_user = user.get(db=db, id=db_user.id)
    assert deleted_user is None
