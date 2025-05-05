from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field

from app.models.feedback import FeedbackPriority


class FeedbackBase(BaseModel):
    """反馈基础模型"""

    feedback_type: str = Field(
        ..., description="反馈类型，如'scooter_damage', 'payment_issue'等"
    )
    feedback_detail: Optional[str] = Field(None, description="反馈详细内容")
    scooter_id: Optional[int] = Field(None, description="相关滑板车ID")
    rental_id: Optional[int] = Field(None, description="相关租赁ID")


class FeedbackCreate(FeedbackBase):
    """创建反馈的请求模型"""

    priority: Optional[str] = Field(None, description="优先级：low, medium, high")


class FeedbackUpdate(BaseModel):
    """更新反馈的请求模型"""

    feedback_type: Optional[str] = None
    feedback_detail: Optional[str] = None
    priority: Optional[str] = None
    status: Optional[str] = None
    resolution_notes: Optional[str] = None


class FeedbackInDBBase(FeedbackBase):
    """数据库中的反馈模型"""

    id: int
    user_id: int
    priority: str
    status: str
    created_at: datetime
    updated_at: datetime
    resolved_at: Optional[datetime] = None
    handled_by: Optional[int] = None
    resolution_notes: Optional[str] = None

    class Config:
        orm_mode = True


class Feedback(FeedbackInDBBase):
    """API响应中的反馈模型"""

    pass


class FeedbackWithDetails(Feedback):
    """包含详细信息的反馈模型，用于管理员视图"""

    user_name: Optional[str] = None
    scooter_model: Optional[str] = None
    handler_name: Optional[str] = None

    class Config:
        from_attributes = True


class FeedbackTypeOption(BaseModel):
    """反馈类型选项模型"""

    value: str
    label: str
    description: str
    priority_default: str = FeedbackPriority.MEDIUM.value


class FeedbackTypeOptions(BaseModel):
    """反馈类型选项列表模型"""

    options: List[FeedbackTypeOption]
