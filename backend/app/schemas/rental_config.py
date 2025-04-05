from typing import Optional, Dict
from pydantic import BaseModel, Field, validator

# class RentalPeriod(BaseModel):
#     one_hour: float = Field(1.0, description="1小时租赁费率（元）")
#     four_hours: float = Field(1.0, description="4小时租赁费率（元）")
#     one_day: float = Field(1.0, description="24小时租赁费率（元）")
#     one_week: float = Field(1.0, description="一周租赁费率（元）")

class RentalConfigBase(BaseModel):
    base_hourly_rate: float = Field(..., gt=0, description="每小时基础费率（元）")
    period_discounts: Dict[str, float] = Field(default={
        '1hr': 1.0,
        '4hrs': 0.9,
        '1day': 0.8,
        '1week': 0.7
    }, description="各时段的折扣率，如：{'1hr': 1.0, '4hrs': 0.9}")
    description: Optional[str] = Field(None, description="配置说明")

    @validator('period_discounts')
    def validate_period_discounts(cls, v):
        for period, discount in v.items():
            if period not in ['1hr', '4hrs', '1day', '1week']:
                raise ValueError(f"Invalid period: {period}")
            if discount < 0 or discount > 1:
                raise ValueError(f"Invalid discount for period {period}: {discount}")
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