from sqlalchemy import Column, Integer, String, Float, ForeignKey, JSON
from sqlalchemy.orm import relationship

from app.db.session import Base


class Scooter(Base):
    __tablename__ = "scooters"

    id = Column(Integer, primary_key=True, index=True)
    model = Column(String, index=True)
    status = Column(String, index=True)  # available, in_use, maintenance, etc.
    battery_level = Column(Integer)  # percentage
    location = Column(JSON)  # JSON with lat and lng

    # Relationships
    rentals = relationship("Rental", back_populates="scooter")