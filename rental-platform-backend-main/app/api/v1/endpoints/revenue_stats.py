from typing import Any, Optional
from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps

router = APIRouter()


@router.get("/daily/{stats_date}", response_model=schemas.revenue_stats.RevenueStats)
async def get_daily_stats(
    stats_date: date,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    获取指定日期的收入统计数据
    """
    # 检查日期是否有效（不能是未来日期）
    if stats_date > date.today():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot get statistics for future dates",
        )

    # 获取或创建该日期的统计数据
    stats = crud.revenue_stats.get_by_date(db, date=stats_date)
    if not stats:
        stats = crud.revenue_stats.create_or_update_daily_stats(
            db, stats_date=stats_date
        )

    return stats


@router.get("/weekly", response_model=schemas.revenue_stats.RevenueSummary)
async def get_weekly_stats(
    end_date: Optional[date] = Query(None, description="统计结束日期，默认为今天"),
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    获取最近一周的收入统计汇总
    """
    # 如果未指定结束日期，则使用今天
    if not end_date:
        end_date = date.today()

    # 检查日期是否有效（不能是未来日期）
    if end_date > date.today():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot get statistics for future dates",
        )

    # 生成周统计数据
    summary = crud.revenue_stats.generate_weekly_stats(db, end_date=end_date)

    return summary


@router.get("/custom", response_model=schemas.revenue_stats.RevenueSummary)
async def get_custom_period_stats(
    start_date: date = Query(..., description="统计开始日期"),
    end_date: date = Query(..., description="统计结束日期"),
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    获取自定义日期范围的收入统计汇总
    """
    # 检查日期是否有效
    today = date.today()
    if start_date > today or end_date > today:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot get statistics for future dates",
        )

    if start_date > end_date:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Start date must be before or equal to end date",
        )

    # 生成自定义日期范围的统计数据
    summary = crud.revenue_stats.generate_custom_period_stats(
        db, start_date=start_date, end_date=end_date
    )

    return summary


@router.post("/refresh/{stats_date}", response_model=schemas.revenue_stats.RevenueStats)
async def refresh_daily_stats(
    stats_date: date,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    刷新指定日期的收入统计数据
    """
    # 检查日期是否有效（不能是未来日期）
    if stats_date > date.today():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot refresh statistics for future dates",
        )

    # 强制更新该日期的统计数据
    stats = crud.revenue_stats.create_or_update_daily_stats(db, stats_date=stats_date)

    return stats
