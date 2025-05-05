from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field


class Coordinate(BaseModel):
    lat: float
    lng: float


class NoParkingZoneBase(BaseModel):
    name: str
    description: Optional[str] = None
    coordinates: List[Coordinate]


class NoParkingZoneCreate(NoParkingZoneBase):
    pass


class NoParkingZoneUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    coordinates: Optional[List[Coordinate]] = None


class NoParkingZone(NoParkingZoneBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
