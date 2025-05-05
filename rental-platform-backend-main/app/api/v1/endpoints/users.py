from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.crud.user import user
from app.schemas.user import HasDiscount, User, UserCreate, UserUpdate

router = APIRouter()


@router.get("/me", response_model=User)
async def read_users_me(current_user=Depends(get_current_user)):
    """
    get current user
    """
    return current_user


@router.get("/", response_model=List[User])
async def read_users(db: Session = Depends(get_db)) -> Any:
    """
    Retrieve users.
    """
    return user.get_multi(db=db)


@router.post("/", response_model=User, status_code=status.HTTP_201_CREATED)
async def create_user(user_in: UserCreate, db: Session = Depends(get_db)) -> Any:
    """
    Create new user.
    """
    # Check if user with this email already exists
    if user.get_by_email(db, email=user_in.email):
        raise HTTPException(
            status_code=400,
            detail="The user with this email already exists in the system.",
        )
    return user.create(db=db, obj_in=user_in)


@router.get("/{user_id}", response_model=User)
async def read_user(user_id: int, db: Session = Depends(get_db)) -> Any:
    """
    Get a specific user by id.
    """
    db_user = user.get(db=db, id=user_id)
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )
    return db_user


@router.put("/{user_id}", response_model=User)
async def update_user(
    user_id: int, user_in: UserUpdate, db: Session = Depends(get_db)
) -> Any:
    """
    Update a user.
    """
    db_user = user.get(db=db, id=user_id)
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )
    return user.update(db=db, db_obj=db_user, obj_in=user_in)


@router.patch("/{user_id}", response_model=User)
async def patch_user(
    user_id: int, user_in: UserUpdate, db: Session = Depends(get_db)
) -> Any:
    """
    Partially update a user.
    """
    db_user = user.get(db=db, id=user_id)
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )
    return user.update(db=db, db_obj=db_user, obj_in=user_in)


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: int, db: Session = Depends(get_db)) -> None:
    """
    Delete a user.
    """
    db_user = user.get(db=db, id=user_id)
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )
    user.remove(db=db, id=user_id)
    return None


@router.get("/has_discount", response_model=HasDiscount)
async def check_discount(
    current_user: User = Depends(get_current_user),
) -> HasDiscount:
    """
    Check if the user has a discount.
    """
    if not current_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    if current_user.age > 60:
        return HasDiscount(has_discount=True, discount=0.8, discount_type="old")

    if current_user.school is not None:
        return HasDiscount(has_discount=True, discount=0.9, discount_type="student")

    return HasDiscount(has_discount=False, discount=1, discount_type="none")
