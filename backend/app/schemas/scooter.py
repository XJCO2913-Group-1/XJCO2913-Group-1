from typing import Optional, Dict

from pydantic import BaseModel, ConfigDict, validator

from enum import Enum

class ScooterStatus(str, Enum):
    AVAILABLE = "available"
    IN_USE = "in_use"
    MAINTENANCE = "maintenance"
    UNAVAILABLE = "unavailable"

class Coordinates(BaseModel):
    lat: float
    lng: float

# Shared properties
class ScooterBase(BaseModel):
    model: Optional[str] = None
    status: Optional[ScooterStatus] = None
    location: Optional[Coordinates] = None  # {"lat": float, "lng": float}
    battery_level: Optional[int] = None  # percentage

    @validator('location')
    def validate_location(cls, v):
        if v:
            if not (-90 <= v.lat <= 90 and -180 <= v.lng <= 180):
                raise ValueError('Invalid location coordinates')
        return v.dict()

# Properties to receive via API on creation
class ScooterCreate(ScooterBase):
    model: str
    status: ScooterStatus = ScooterStatus.AVAILABLE
    battery_level: int = 100

# Properties to receive via API on update
class ScooterUpdate(ScooterBase):
    pass

class ScooterInDBBase(ScooterBase):
    id: Optional[int] = None
    model_config = ConfigDict(from_attributes=True)

# Properties to return to client
class Scooter(ScooterInDBBase):
    pass

# Additional properties stored in DB
class ScooterInDB(ScooterInDBBase):
    pass