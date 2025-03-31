from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from sqlalchemy.orm import relationship

from app.db.session import Base


class PaymentCard(Base):
    __tablename__ = "payment_cards"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    card_holder_name = Column(String)
    # 存储加密后的卡号，只保留最后4位明文
    card_number_last4 = Column(String(4))
    encrypted_card_number = Column(String)
    card_expiry_month = Column(String(2))
    card_expiry_year = Column(String(2))
    # 存储加密后的CVV
    encrypted_cvv = Column(String)
    card_type = Column(String)  # visa, mastercard, etc.
    is_default = Column(Boolean, default=False)
    
    # Relationships
    user = relationship("User", back_populates="payment_cards")
    payments = relationship("Payment", back_populates="payment_card")