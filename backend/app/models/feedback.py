from sqlalchemy import Column, Integer, String, Text, DateTime, Enum, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from enum import Enum as PyEnum
from datetime import datetime

from app.db.session import Base


class FeedbackPriority(str, PyEnum):
    """反馈优先级枚举"""
    LOW = "low"  # 低优先级
    MEDIUM = "medium"  # 中优先级
    HIGH = "high"  # 高优先级


class FeedbackStatus(str, PyEnum):
    """反馈状态枚举"""
    PENDING = "pending"  # 待处理
    IN_PROGRESS = "in_progress"  # 处理中
    RESOLVED = "resolved"  # 已解决
    CLOSED = "closed"  # 已关闭


class FeedbackType(str, PyEnum):
    """反馈类型枚举"""
    SCOOTER_DAMAGE = "scooter_damage"  # 滑板车损坏
    PAYMENT_ISSUE = "payment_issue"  # 支付问题
    APP_ISSUE = "app_issue"  # 应用问题
    RENTAL_ISSUE = "rental_issue"  # 租赁问题
    OTHER = "other"  # 其他


class Feedback(Base):
    """用户反馈模型"""
    __tablename__ = "feedbacks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    scooter_id = Column(Integer, ForeignKey("scooters.id"), nullable=True)
    rental_id = Column(Integer, ForeignKey("rentals.id"), nullable=True)
    
    # 反馈类型和内容
    feedback_type = Column(String, nullable=False)
    feedback_detail = Column(Text, nullable=True)  # 用户自定义反馈内容
    
    # 优先级和状态
    priority = Column(String, default=FeedbackPriority.MEDIUM.value)
    status = Column(String, default=FeedbackStatus.PENDING.value)
    
    # 时间戳
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    resolved_at = Column(DateTime, nullable=True)
    
    # 处理信息
    handled_by = Column(Integer, ForeignKey("users.id"), nullable=True)  # 处理人员ID
    resolution_notes = Column(Text, nullable=True)  # 解决方案说明
    
    # 关系
    user = relationship("User", foreign_keys=[user_id], back_populates="feedbacks")
    handler = relationship("User", foreign_keys=[handled_by], backref="handled_feedbacks")
    scooter = relationship("Scooter", back_populates="feedbacks")
    rental = relationship("Rental", back_populates="feedbacks")