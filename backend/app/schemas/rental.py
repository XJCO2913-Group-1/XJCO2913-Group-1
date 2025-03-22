from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum
from pydantic import BaseModel, ConfigDict


class RentalPeriod(str, Enum):
    ONE_HOUR = "1hr"
    FOUR_HOURS = "4hrs"
    ONE_DAY = "1day"
    ONE_WEEK = "1week"


class RentalStatus(str, Enum):
    ACTIVE = "active"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


# Shared properties
class RentalBase(BaseModel):
    scooter_id: Optional[int] = None
    user_id: Optional[int] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    status: Optional[RentalStatus] = None
    cost: Optional[float] = None
    rental_period: Optional[RentalPeriod] = None


# Properties to receive via API on creation
class RentalCreate(RentalBase):
    scooter_id: int
    rental_period: RentalPeriod
    status: RentalStatus = RentalStatus.ACTIVE


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
