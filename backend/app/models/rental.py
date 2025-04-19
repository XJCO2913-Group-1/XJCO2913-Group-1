from sqlalchemy import Column, Integer, Float, ForeignKey, DateTime, Enum

from sqlalchemy.orm import relationship


from app.db.session import Base

from app.schemas.rental import RentalStatus


class Rental(Base):
    __tablename__ = "rentals"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"))

    scooter_id = Column(Integer, ForeignKey("scooters.id"))

    start_time = Column(DateTime, index=True)

    end_time = Column(DateTime, nullable=True)

    status = Column(Enum(RentalStatus), default=RentalStatus.ACTIVE)
    cost = Column(Float, nullable=True)

    # Relationships

    user = relationship("User", back_populates="rentals")

    scooter = relationship("Scooter", back_populates="rentals")

    feedbacks = relationship("Feedback", back_populates="rental")
