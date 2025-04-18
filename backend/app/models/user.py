from sqlalchemy import Boolean, Column, Integer, String
from sqlalchemy.orm import relationship

from app.db.session import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)

    age = Column(Integer, nullable=True)
    school = Column(
        String, nullable=True
    )  # if school is not None, it means the user is a student

    # Relationships
    rentals = relationship("Rental", back_populates="user")
    payment_cards = relationship("PaymentCard", back_populates="user")
    feedbacks = relationship(
        "Feedback", foreign_keys="[Feedback.user_id]", back_populates="user"
    )
    conversations = relationship("Conversation", back_populates="user")
