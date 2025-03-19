from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum
from pydantic import BaseModel, ConfigDict


class RentalPeriod(str, Enum):
    ONE_HOUR = "1hr"
    FOUR_HOURS = "4hrs"
    ONE_DAY = "1day"
    ONE_WEEK = "1week"


# Shared properties
class RentalBase(BaseModel):
    scooter_id: Optional[int] = None
    user_id: Optional[int] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    status: Optional[str] = None  # active, completed, cancelled
    start_location: Optional[str] = None
    end_location: Optional[str] = None
    cost: Optional[float] = None
    rental_period: Optional[RentalPeriod] = None


# Properties to receive via API on creation
class RentalCreate(RentalBase):
    scooter_id: int
    user_id: int
    start_time: datetime
    start_location: str
    rental_period: RentalPeriod
    status: str = "active"


# Properties to receive via API on update
class RentalUpdate(RentalBase):
    pass


class RentalInDBBase(RentalBase):
    id: Optional[int] = None
    model_config = ConfigDict(from_attributes=True)


# Additional properties to return via API
class Rental(RentalInDBBase):
    pass


# Additional properties stored in DB
class RentalInDB(RentalInDBBase):
    pass