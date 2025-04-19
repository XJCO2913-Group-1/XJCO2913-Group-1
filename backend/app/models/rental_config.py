from sqlalchemy import Column, Integer, Float, String, JSON
from app.db.session import Base


class RentalConfig(Base):
    __tablename__ = "rental_configs"

    id = Column(Integer, primary_key=True, index=True)
    base_hourly_rate = Column(Float, nullable=False, default=20.0)
    period_discounts = Column(JSON, nullable=False)
    description = Column(String, nullable=True)
    is_active = Column(Integer, nullable=False, default=1)  # 1表示当前生效的配置
