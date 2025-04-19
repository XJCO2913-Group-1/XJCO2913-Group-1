from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Enum
from sqlalchemy.orm import relationship
from enum import Enum as PyEnum
from datetime import datetime

from app.db.session import Base


class PaymentStatus(str, PyEnum):
    PENDING = "pending"
    COMPLETED = "completed"
    FAILED = "failed"
    REFUNDED = "refunded"


class PaymentMethod(str, PyEnum):
    CARD = "card"
    SAVED_CARD = "saved_card"


class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    rental_id = Column(Integer, ForeignKey("rentals.id"))
    payment_card_id = Column(Integer, ForeignKey("payment_cards.id"), nullable=True)
    amount = Column(Float, nullable=False)
    currency = Column(String, default="CNY")
    status = Column(Enum(PaymentStatus), default=PaymentStatus.PENDING)
    payment_method = Column(Enum(PaymentMethod))
    transaction_id = Column(String, nullable=True)  # 外部支付网关的交易ID
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User")
    rental = relationship("Rental")
    payment_card = relationship("PaymentCard", back_populates="payments")
