from typing import Optional

from pydantic import BaseModel, EmailStr, ConfigDict


# Shared properties
class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    is_active: Optional[bool] = True
    name: Optional[str] = None
    age: Optional[int] = None
    school: Optional[str] = (
        None  # if school is not None, it means the user is a student
    )


# Properties to receive via API on creation
class UserCreate(UserBase):
    email: EmailStr
    password: str
    name: str


# Properties to receive via API on update
class UserUpdate(UserBase):
    password: Optional[str] = None


class UserInDBBase(UserBase):
    id: Optional[int] = None
    model_config = ConfigDict(from_attributes=True)


# Additional properties to return via API
class User(UserInDBBase):
    pass


# Additional properties stored in DB
class UserInDB(UserInDBBase):
    hashed_password: str


class HasDiscount(BaseModel):
    has_discount: bool
    dis_count: float = 1
    discout_type: Optional[str] = None  # "student" or "old"
