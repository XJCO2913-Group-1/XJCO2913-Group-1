from typing import Optional, List, Union
from datetime import datetime
from pydantic import BaseModel, Field, ConfigDict

from app.models.payment import PaymentStatus, PaymentMethod


# 共享属性
class PaymentBase(BaseModel):
    amount: Optional[float] = None
    currency: Optional[str] = "CNY"
    payment_method: Optional[PaymentMethod] = None
    status: Optional[PaymentStatus] = None


# 用于创建新支付的请求
class PaymentCreate(PaymentBase):
    rental_id: int
    amount: float
    payment_method: PaymentMethod
    payment_card_id: Optional[int] = None  # 如果使用已保存的卡，提供卡ID
    card_details: Optional[dict] = None  # 如果使用新卡，提供卡详情


# 用于更新支付状态的请求
class PaymentUpdate(PaymentBase):
    status: Optional[PaymentStatus] = None
    transaction_id: Optional[str] = None


# 支付网关响应模拟
class PaymentGatewayResponse(BaseModel):
    success: bool
    transaction_id: Optional[str] = None
    error_message: Optional[str] = None
    status: str


# 数据库中的基本支付信息
class PaymentInDBBase(PaymentBase):
    id: Optional[int] = None
    user_id: int
    rental_id: int
    payment_card_id: Optional[int] = None
    transaction_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    
    model_config = ConfigDict(from_attributes=True)


# API返回的支付信息
class Payment(PaymentInDBBase):
    pass


# 数据库中存储的完整支付信息
class PaymentInDB(PaymentInDBBase):
    pass


# 支付确认响应
class PaymentConfirmation(BaseModel):
    payment_id: int
    status: PaymentStatus
    transaction_id: Optional[str] = None
    message: str
    rental_id: int
    amount: float
    currency: str
    payment_method: PaymentMethod
    payment_date: datetime