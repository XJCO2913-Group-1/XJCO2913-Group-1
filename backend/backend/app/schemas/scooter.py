from typing import Optional, Dict

from pydantic import BaseModel, ConfigDict

# Shared properties
class ScooterBase(BaseModel):
    model: Optional[str] = None
    status: Optional[str] = None  # available, in_use, maintenance
    location: Optional[Dict[str, float]] = None  # {"lat": float, "lng": float}
    battery_level: Optional[int] = None  # percentage

# Properties to receive via API on creation
class ScooterCreate(ScooterBase):
    model: str
    status: str = "available"
    location: Dict[str, float]  # {"lat": float, "lng": float}
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