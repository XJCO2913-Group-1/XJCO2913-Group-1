from typing import Optional
from pydantic import BaseModel, Field, ConfigDict, validator
import re


# 共享属性
class PaymentCardBase(BaseModel):
    card_holder_name: Optional[str] = None
    card_number: Optional[str] = None
    card_expiry_month: Optional[str] = None
    card_expiry_year: Optional[str] = None
    cvv: Optional[str] = None
    card_type: Optional[str] = None
    is_default: Optional[bool] = False

    @validator("card_number", pre=True)
    def validate_card_number(cls, v):
        if v is None:
            return v
        # 移除空格和破折号
        v = re.sub(r"[\s-]", "", v)
        # 检查是否只包含数字
        if not v.isdigit():
            raise ValueError("卡号必须只包含数字")
        # 检查长度是否在13-19之间
        if not (13 <= len(v) <= 19):
            raise ValueError("卡号长度必须在13到19位之间")
        return v

    @validator("card_expiry_month")
    def validate_expiry_month(cls, v):
        if v is None:
            return v
        # 移除空格
        v = v.strip()
        # 检查是否只包含数字
        if not v.isdigit():
            raise ValueError("到期月份必须只包含数字")
        # 检查月份是否有效
        month = int(v)
        if not (1 <= month <= 12):
            raise ValueError("到期月份必须在1到12之间")
        # 格式化为两位数
        return v.zfill(2)

    @validator("card_expiry_year")
    def validate_expiry_year(cls, v):
        if v is None:
            return v
        # 移除空格
        v = v.strip()
        # 检查是否只包含数字
        if not v.isdigit():
            raise ValueError("到期年份必须只包含数字")
        # 如果是两位数，确保是有效的年份
        if len(v) == 2:
            return v
        # 如果是四位数，取后两位
        elif len(v) == 4:
            return v[2:]
        else:
            raise ValueError("到期年份格式无效")

    @validator("cvv")
    def validate_cvv(cls, v):
        if v is None:
            return v
        # 移除空格
        v = v.strip()
        # 检查是否只包含数字
        if not v.isdigit():
            raise ValueError("CVV必须只包含数字")
        # 检查长度是否为3或4
        if len(v) not in [3, 4]:
            raise ValueError("CVV长度必须为3或4位")
        return v


# 用于创建支付卡的请求
class PaymentCardCreate(PaymentCardBase):
    card_holder_name: str
    card_number: str
    card_expiry_month: str
    card_expiry_year: str
    cvv: str
    save_for_future: bool = Field(
        default=False, description="是否保存卡信息用于将来支付"
    )


# 用于更新支付卡的请求
class PaymentCardUpdate(PaymentCardBase):
    pass


# 数据库中的基本支付卡信息
class PaymentCardInDBBase(BaseModel):
    id: Optional[int] = None
    user_id: int
    card_holder_name: str
    card_number_last4: str
    card_expiry_month: str
    card_expiry_year: str
    card_type: str
    is_default: bool

    model_config = ConfigDict(from_attributes=True)


# API返回的支付卡信息
class PaymentCard(PaymentCardInDBBase):
    pass


# 数据库中存储的完整支付卡信息
class PaymentCardInDB(PaymentCardInDBBase):
    encrypted_card_number: str
    encrypted_cvv: str
