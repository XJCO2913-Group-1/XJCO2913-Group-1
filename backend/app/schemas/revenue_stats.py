from typing import Dict, Optional, List, Any
from datetime import date, datetime
from pydantic import BaseModel, Field, field_validator


class RevenuePeriodStats(BaseModel):
    """按租赁时长分类的收入统计"""

    count: int = Field(0, description="租赁订单数量")
    revenue: float = Field(0.0, description="收入金额")
    average_daily: float = Field(0.0, description="平均每日收入")


class RevenuePeriodData(BaseModel):
    """单个时长的收入数据"""

    count: int = Field(0, description="租赁订单数量")
    revenue: float = Field(0.0, description="收入金额")


class RevenueStatsBase(BaseModel):
    """收入统计基础模型"""

    date: datetime = Field(..., description="统计日期")
    total_revenue: float = Field(..., description="总收入")
    rental_count: int = Field(..., description="租赁订单总数")
    revenue_by_period: Dict[str, RevenuePeriodData] = Field(
        default_factory=lambda: {
            "1hr": RevenuePeriodData(),
            "4hrs": RevenuePeriodData(),
            "1day": RevenuePeriodData(),
            "1week": RevenuePeriodData(),
        },
        description="按租赁时长分类的收入数据",
    )

    # @field_validator("date")
    # def date_must_not_be_in_future(cls, v):
    #     return v.date()


class RevenueStatsCreate(RevenueStatsBase):
    """创建收入统计的请求模型"""

    pass


class RevenueStatsInDB(RevenueStatsBase):
    """数据库中的收入统计模型"""

    id: int
    created_at: datetime

    class Config:
        from_attributes = True


class RevenueStats(RevenueStatsInDB):
    """API响应中的收入统计模型"""

    pass


class RevenueSummary(BaseModel):
    """收入汇总统计模型，用于周期性统计"""

    start_date: datetime = Field(..., description="统计开始日期")
    end_date: datetime = Field(..., description="统计结束日期")
    total_revenue: float = Field(..., description="总收入")
    total_rentals: int = Field(..., description="总租赁订单数")
    daily_average: float = Field(..., description="日均收入")
    revenue_by_period: Dict[str, RevenuePeriodStats] = Field(
        default_factory=lambda: {
            "1hr": RevenuePeriodStats(),
            "4hrs": RevenuePeriodStats(),
            "1day": RevenuePeriodStats(),
            "1week": RevenuePeriodStats(),
        },
        description="按租赁时长分类的收入统计",
    )
    daily_stats: List[Dict[str, Any]] = Field(..., description="每日收入统计数据")


class RevenueQueryParams(BaseModel):
    """收入查询参数模型"""

    start_date: Optional[datetime] = Field(None, description="开始日期")
    end_date: Optional[datetime] = Field(None, description="结束日期")

    @field_validator("end_date")
    def end_date_must_be_after_start_date(cls, v, info):
        if "start_date" in info.data and info.data["start_date"] and v:
            if v < info.data["start_date"]:
                raise ValueError("结束日期必须晚于开始日期")
        return v

    @field_validator("start_date", "end_date")
    def date_must_not_be_in_future(cls, v):
        if v and v > date.today():
            raise ValueError("日期不能是未来日期")
        return v
