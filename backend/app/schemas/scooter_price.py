from pydantic import BaseModel, Field


# Shared properties
class ScooterPriceBase(BaseModel):
    model: str | None = None
    price_per_hour: float | None = Field(None, gt=0)


# Properties to receive on item creation
class ScooterPriceCreate(ScooterPriceBase):
    model: str
    price_per_hour: float = Field(..., gt=0)


# Properties to receive on item update
class ScooterPriceUpdate(ScooterPriceBase):
    pass


# Properties shared by models stored in DB
class ScooterPriceInDBBase(ScooterPriceBase):
    id: int
    model: str
    price_per_hour: float

    class Config:
        orm_mode = True


# Properties to return to client
class ScooterPrice(ScooterPriceInDBBase):
    pass


# Properties properties stored in DB
class ScooterPriceInDB(ScooterPriceInDBBase):
    pass
