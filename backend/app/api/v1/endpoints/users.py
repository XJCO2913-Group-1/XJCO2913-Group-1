from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status

from app.schemas.user import User, UserCreate, UserUpdate

router = APIRouter()


@router.get("/", response_model=List[User])
async def read_users() -> Any:
    """
    Retrieve users.
    """
    # This is a placeholder for actual implementation
    # In a real implementation, you would fetch users from your database
    return [
        {"id": 1, "email": "user1@example.com", "is_active": True},
        {"id": 2, "email": "user2@example.com", "is_active": False},
    ]


@router.post("/", response_model=User, status_code=status.HTTP_201_CREATED)
async def create_user(user_in: UserCreate) -> Any:
    """
    Create new user.
    """
    # This is a placeholder for actual implementation
    # In a real implementation, you would create a user in your database
    return {"id": 3, "email": user_in.email, "is_active": True}


@router.get("/{user_id}", response_model=User)
async def read_user(user_id: int) -> Any:
    """
    Get a specific user by id.
    """
    # This is a placeholder for actual implementation
    # In a real implementation, you would fetch a specific user from your database
    return {"id": user_id, "email": f"user{user_id}@example.com", "is_active": True}


@router.put("/{user_id}", response_model=User)
async def update_user(user_id: int, user_in: UserUpdate) -> Any:
    """
    Update a user.
    """
    # This is a placeholder for actual implementation
    # In a real implementation, you would update a user in your database
    return {"id": user_id, "email": user_in.email, "is_active": user_in.is_active}


@router.delete("/{user_id}", response_model=User)
async def delete_user(user_id: int) -> Any:
    """
    Delete a user.
    """
    # This is a placeholder for actual implementation
    # In a real implementation, you would delete a user from your database
    return {"id": user_id, "email": f"user{user_id}@example.com", "is_active": False}