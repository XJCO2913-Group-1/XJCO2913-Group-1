from typing import Optional, Dict
from pydantic import BaseModel, Field, validator

class RentalConfigBase(BaseModel):
    base_hourly_rate: float = Field(..., gt=0, description="每小时基础费率（元）")
    period_discounts: Dict[str, float] = Field(..., description="各时段的折扣率，如：{'ONE_HOUR': 1.0, 'FOUR_HOURS': 0.9}")
    description: Optional[str] = Field(None, description="配置说明")
    
    @validator('period_discounts')
    def validate_period_discounts(cls, v):
        for period, discount in v.items():
            if not 0 <= discount <= 1:
                raise ValueError(f"Discount rate must be between 0 and 1, got {discount} for period {period}")
        return v

class RentalConfigCreate(RentalConfigBase):
    pass

class RentalConfigUpdate(RentalConfigBase):
    base_hourly_rate: Optional[float] = Field(None, gt=0)
    period_discounts: Optional[Dict[str, float]] = None

class RentalConfig(RentalConfigBase):
    id: int
    is_active: int

    class Config:
        from_attributes = True