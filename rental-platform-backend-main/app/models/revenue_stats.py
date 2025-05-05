from sqlalchemy import Column, Integer, Float, Date, JSON
from datetime import datetime
from app.db.session import Base


class RevenueStats(Base):
    """收入统计模型，用于记录每日收入数据"""

    __tablename__ = "revenue_stats"

    id = Column(Integer, primary_key=True, index=True)
    date = Column(Date, nullable=False, index=True, unique=True)  # 统计日期
    total_revenue = Column(Float, nullable=False, default=0.0)  # 总收入
    rental_count = Column(Integer, nullable=False, default=0)  # 租赁订单总数

    # 按租赁时长分类的收入数据，存储为JSON格式
    # 例如: {"1hr": {"count": 10, "revenue": 200.0}, "4hrs": {"count": 5, "revenue": 300.0}, ...}
    revenue_by_period = Column(JSON, nullable=False, default={})

    # 创建日期（用于记录该统计记录的创建时间）
    created_at = Column(Date, nullable=False, default=datetime.utcnow)
