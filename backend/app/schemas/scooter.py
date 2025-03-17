from typing import Optional

from pydantic import BaseModel


# Shared properties
class ScooterBase(BaseModel):
    model: Optional[str] = None
    status: Optional[str] = None  # available, in_use, maintenance
    location: Optional[str] = None
    battery_level: Optional[int] = None  # percentage


# Properties to receive via API on creation
class ScooterCreate(ScooterBase):
    model: str
    status: str = "available"
    location: str
    battery_level: int = 100


# Properties to receive via API on update
class ScooterUpdate(ScooterBase):
    pass


class ScooterInDBBase(ScooterBase):
    id: Optional[int] = None

    class Config:
        from_attributes = True


# Additional properties to return via API
class Scooter(ScooterInDBBase):
    pass


# Additional properties stored in DB
class ScooterInDB(ScooterInDBBase):
    pass