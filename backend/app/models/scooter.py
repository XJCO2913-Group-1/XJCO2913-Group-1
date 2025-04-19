from sqlalchemy import Column, Integer, String, JSON, Enum
from sqlalchemy.orm import relationship

from app.db.session import Base
from app.schemas.scooter import ScooterStatus


class Scooter(Base):
    __tablename__ = "scooters"

    status = Column(Enum(ScooterStatus), default=ScooterStatus.AVAILABLE)
    id = Column(Integer, primary_key=True, index=True)
    model = Column(String, index=True)
    status = Column(String, index=True)  # available, in_use, maintenance, etc.
    battery_level = Column(Integer)  # percentage
    location = Column(JSON)  # JSON with lat and lng

    # Relationships
    rentals = relationship("Rental", back_populates="scooter")
    feedbacks = relationship("Feedback", back_populates="scooter")
