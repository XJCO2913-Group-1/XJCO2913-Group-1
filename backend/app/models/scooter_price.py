from sqlalchemy import Column, Integer, String, Float, UniqueConstraint

from app.db.session import Base


class ScooterPrice(Base):
    __tablename__ = "scooter_prices"

    id = Column(Integer, primary_key=True, index=True)
    model = Column(String, index=True, unique=True, nullable=False)
    price_per_hour = Column(Float, nullable=False)

    __table_args__ = (UniqueConstraint("model", name="uq_scooter_model"),)
