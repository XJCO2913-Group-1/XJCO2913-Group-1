from typing import List, Optional, Dict, Any
from datetime import date, datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, between

from app.crud.base import CRUDBase
from app.models.revenue_stats import RevenueStats
from app.models.rental import Rental
from app.models.payment import Payment, PaymentStatus
from app.schemas.revenue_stats import RevenueStatsCreate, RevenueSummary
from app.schemas.rental import RentalPeriod, RentalStatus


class CRUDRevenueStats(CRUDBase[RevenueStats, RevenueStatsCreate, dict]):
    def get_by_date(self, db: Session, *, date: date) -> Optional[RevenueStats]:
        """根据日期获取收入统计数据"""
        return db.query(RevenueStats).filter(RevenueStats.date == date).first()
    
    def get_date_range(self, db: Session, *, start_date: date, end_date: date) -> List[RevenueStats]:
        """获取指定日期范围内的收入统计数据"""
        return db.query(RevenueStats).filter(
            RevenueStats.date >= start_date,
            RevenueStats.date <= end_date
        ).order_by(RevenueStats.date).all()
    
    def create_or_update_daily_stats(self, db: Session, *, stats_date: date) -> RevenueStats:
        """创建或更新指定日期的收入统计数据"""
        # 查找是否已存在该日期的统计数据
        stats = self.get_by_date(db, date=stats_date)
        
        # 获取指定日期的所有已支付租赁订单
        start_of_day = datetime.combine(stats_date, datetime.min.time())
        end_of_day = datetime.combine(stats_date, datetime.max.time())
        
        # 查询当天完成支付的所有租赁订单
        payments = db.query(Payment).filter(
            Payment.status == PaymentStatus.COMPLETED,
            Payment.created_at >= start_of_day,
            Payment.created_at <= end_of_day
        ).all()
        
        # 初始化统计数据
        total_revenue = 0.0
        rental_count = 0
        revenue_by_period = {
            RentalPeriod.ONE_HOUR.value: {"count": 0, "revenue": 0.0},
            RentalPeriod.FOUR_HOURS.value: {"count": 0, "revenue": 0.0},
            RentalPeriod.ONE_DAY.value: {"count": 0, "revenue": 0.0},
            RentalPeriod.ONE_WEEK.value: {"count": 0, "revenue": 0.0}
        }
        
        # 统计收入数据
        for payment in payments:
            rental = db.query(Rental).filter(Rental.id == payment.rental_id).first()
            if rental and rental.status in [RentalStatus.COMPLETED, RentalStatus.PAID]:
                total_revenue += payment.amount
                rental_count += 1
                
                # 根据租赁时长分类统计
                # 计算租赁时长（小时）
                if rental.end_time and rental.start_time:
                    duration_hours = (rental.end_time - rental.start_time).total_seconds() / 3600
                    
                    # 根据时长判断租赁类型
                    rental_period = None
                    if duration_hours <= 1.5:  # 1小时租赁（允许一些误差）
                        rental_period = RentalPeriod.ONE_HOUR.value
                    elif duration_hours <= 5:  # 4小时租赁
                        rental_period = RentalPeriod.FOUR_HOURS.value
                    elif duration_hours <= 25:  # 1天租赁
                        rental_period = RentalPeriod.ONE_DAY.value
                    else:  # 1周租赁
                        rental_period = RentalPeriod.ONE_WEEK.value
                    
                    if rental_period:
                        revenue_by_period[rental_period]["count"] += 1
                        revenue_by_period[rental_period]["revenue"] += payment.amount
        
        # 创建或更新统计数据
        if not stats:
            # 创建新的统计记录
            stats_data = {
                "date": stats_date,
                "total_revenue": total_revenue,
                "rental_count": rental_count,
                "revenue_by_period": revenue_by_period
            }
            stats = RevenueStats(**stats_data)
            db.add(stats)
        else:
            # 更新现有统计记录
            stats.total_revenue = total_revenue
            stats.rental_count = rental_count
            stats.revenue_by_period = revenue_by_period
        
        db.commit()
        db.refresh(stats)
        return stats
    
    def generate_weekly_stats(self, db: Session, *, end_date: date = None) -> RevenueSummary:
        """生成最近一周的收入统计汇总"""
        if not end_date:
            end_date = date.today()
        
        start_date = end_date - timedelta(days=6)  # 7天的数据（包括结束日期）
        
        # 获取日期范围内的所有统计数据
        daily_stats = self.get_date_range(db, start_date=start_date, end_date=end_date)
        
        # 如果某天没有统计数据，则创建该天的统计
        current_date = start_date
        while current_date <= end_date:
            found = False
            for stats in daily_stats:
                if stats.date == current_date:
                    found = True
                    break
            
            if not found:
                self.create_or_update_daily_stats(db, stats_date=current_date)
            
            current_date += timedelta(days=1)
        
        # 重新获取完整的统计数据
        daily_stats = self.get_date_range(db, start_date=start_date, end_date=end_date)
        
        # 初始化汇总数据
        total_revenue = 0.0
        total_rentals = 0
        revenue_by_period = {
            RentalPeriod.ONE_HOUR.value: {"count": 0, "revenue": 0.0, "average_daily": 0.0},
            RentalPeriod.FOUR_HOURS.value: {"count": 0, "revenue": 0.0, "average_daily": 0.0},
            RentalPeriod.ONE_DAY.value: {"count": 0, "revenue": 0.0, "average_daily": 0.0},
            RentalPeriod.ONE_WEEK.value: {"count": 0, "revenue": 0.0, "average_daily": 0.0}
        }
        
        # 汇总数据
        daily_data = []
        for stats in daily_stats:
            total_revenue += stats.total_revenue
            total_rentals += stats.rental_count
            
            # 按租赁时长汇总
            for period, data in stats.revenue_by_period.items():
                if period in revenue_by_period:
                    revenue_by_period[period]["count"] += data["count"]
                    revenue_by_period[period]["revenue"] += data["revenue"]
            
            # 添加每日数据
            daily_data.append({
                "date": stats.date.isoformat(),
                "total_revenue": stats.total_revenue,
                "rental_count": stats.rental_count,
                "revenue_by_period": stats.revenue_by_period
            })
        
        # 计算日均收入和每种租赁类型的日均收入
        days_count = (end_date - start_date).days + 1
        daily_average = total_revenue / days_count if days_count > 0 else 0
        
        for period in revenue_by_period:
            revenue_by_period[period]["average_daily"] = (
                revenue_by_period[period]["revenue"] / days_count if days_count > 0 else 0
            )
        
        # 创建汇总结果
        summary = RevenueSummary(
            start_date=start_date,
            end_date=end_date,
            total_revenue=total_revenue,
            total_rentals=total_rentals,
            daily_average=daily_average,
            revenue_by_period=revenue_by_period,
            daily_stats=daily_data
        )
        
        return summary
    
    def generate_custom_period_stats(self, db: Session, *, start_date: date, end_date: date) -> RevenueSummary:
        """生成自定义日期范围的收入统计汇总"""
        # 确保开始日期不晚于结束日期
        if start_date > end_date:
            start_date, end_date = end_date, start_date
        
        # 获取日期范围内的所有统计数据
        daily_stats = self.get_date_range(db, start_date=start_date, end_date=end_date)
        
        # 如果某天没有统计数据，则创建该天的统计
        current_date = start_date
        while current_date <= end_date:
            found = False
            for stats in daily_stats:
                if stats.date == current_date:
                    found = True
                    break
            
            if not found:
                self.create_or_update_daily_stats(db, stats_date=current_date)
            
            current_date += timedelta(days=1)
        
        # 重新获取完整的统计数据
        daily_stats = self.get_date_range(db, start_date=start_date, end_date=end_date)
        
        # 初始化汇总数据
        total_revenue = 0.0
        total_rentals = 0
        revenue_by_period = {
            RentalPeriod.ONE_HOUR.value: {"count": 0, "revenue": 0.0, "average_daily": 0.0},
            RentalPeriod.FOUR_HOURS.value: {"count": 0, "revenue": 0.0, "average_daily": 0.0},
            RentalPeriod.ONE_DAY.value: {"count": 0, "revenue": 0.0, "average_daily": 0.0},
            RentalPeriod.ONE_WEEK.value: {"count": 0, "revenue": 0.0, "average_daily": 0.0}
        }
        
        # 汇总数据
        daily_data = []
        for stats in daily_stats:
            total_revenue += stats.total_revenue
            total_rentals += stats.rental_count
            
            # 按租赁时长汇总
            for period, data in stats.revenue_by_period.items():
                if period in revenue_by_period:
                    revenue_by_period[period]["count"] += data["count"]
                    revenue_by_period[period]["revenue"] += data["revenue"]
            
            # 添加每日数据
            daily_data.append({
                "date": stats.date.isoformat(),
                "total_revenue": stats.total_revenue,
                "rental_count": stats.rental_count,
                "revenue_by_period": stats.revenue_by_period
            })
        
        # 计算日均收入和每种租赁类型的日均收入
        days_count = (end_date - start_date).days + 1
        daily_average = total_revenue / days_count if days_count > 0 else 0
        
        for period in revenue_by_period:
            revenue_by_period[period]["average_daily"] = (
                revenue_by_period[period]["revenue"] / days_count if days_count > 0 else 0
            )
        
        # 创建汇总结果
        summary = RevenueSummary(
            start_date=start_date,
            end_date=end_date,
            total_revenue=total_revenue,
            total_rentals=total_rentals,
            daily_average=daily_average,
            revenue_by_period=revenue_by_period,
            daily_stats=daily_data
        )
        
        return summary


# 创建CRUD实例
revenue_stats = CRUDRevenueStats(RevenueStats)