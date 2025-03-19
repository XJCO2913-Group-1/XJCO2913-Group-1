from typing import Any, List
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps
from app.schemas.rental import Rental, RentalCreate, RentalUpdate, RentalPeriod
from app.api.deps import get_db
# from app.core.email import send_rental_confirmation

router = APIRouter()

# 租赁时长对应的小时数
RENTAL_PERIOD_HOURS = {
    RentalPeriod.ONE_HOUR: 1,
    RentalPeriod.FOUR_HOURS: 4,
    RentalPeriod.ONE_DAY: 24,
    RentalPeriod.ONE_WEEK: 168
}

# 每小时基础费率（元）
BASE_HOURLY_RATE = 20.0


def calculate_rental_cost(rental_period: RentalPeriod) -> float:
    hours = RENTAL_PERIOD_HOURS[rental_period]
    # 根据租赁时长提供不同的折扣
    if rental_period == RentalPeriod.ONE_WEEK:
        discount = 0.7  # 周租70%的价格
    elif rental_period == RentalPeriod.ONE_DAY:
        discount = 0.8  # 天租80%的价格
    elif rental_period == RentalPeriod.FOUR_HOURS:
        discount = 0.9  # 4小时租90%的价格
    else:
        discount = 1.0  # 1小时无折扣
    
    return hours * BASE_HOURLY_RATE * discount


@router.get("/", response_model=List[Rental])
async def read_rentals(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """获取租赁列表"""
    rentals = crud.rental.get_multi(db, skip=skip, limit=limit)
    return rentals


@router.post("/", response_model=Rental, status_code=status.HTTP_201_CREATED)
async def create_rental(
    rental_in: RentalCreate,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """创建新的租赁订单"""
    # 检查滑板车是否可用
    scooter = crud.scooter.get(db, id=rental_in.scooter_id)
    if not scooter:
        raise HTTPException(
            status_code=404,
            detail="Scooter not found"
        )
    if scooter.status != "available":
        raise HTTPException(
            status_code=400,
            detail="Scooter is not available"
        )
    
    # 计算租赁费用和结束时间
    rental_cost = calculate_rental_cost(rental_in.rental_period)
    end_time = rental_in.start_time + timedelta(hours=RENTAL_PERIOD_HOURS[rental_in.rental_period])
    rental_in.end_time = end_time
    
    # 创建租赁记录并更新滑板车状态
    rental = crud.rental.create_with_scooter(
        db=db,
        rental_in=rental_in,
        user_id=current_user.id,
        total_cost=rental_cost
    )
    
    return rental


@router.get("/{rental_id}", response_model=Rental)
async def read_rental(
    rental_id: int,
    db: Session = Depends(deps.get_db)
) -> Any:
    """获取特定租赁记录"""
    rental = crud.rental.get_by_id(db, rental_id)
    if not rental:
        raise HTTPException(
            status_code=404,
            detail="Rental not found"
        )
    return rental


@router.put("/{rental_id}", response_model=Rental)
async def update_rental(
    rental_id: int,
    rental_in: RentalUpdate,
    db: Session = Depends(deps.get_db)
) -> Any:
    """更新租赁记录"""
    rental = crud.rental.get_by_id(db, rental_id)
    if not rental:
        raise HTTPException(
            status_code=404,
            detail="Rental not found"
        )
    rental = crud.rental.update_rental(db, rental=rental, rental_in=rental_in)
    return rental


@router.delete("/{rental_id}", response_model=Rental)
async def delete_rental(
    rental_id: int,
    db: Session = Depends(deps.get_db)
) -> Any:
    """删除租赁记录"""
    rental = crud.rental.delete_rental(db, rental_id=rental_id)
    if not rental:
        raise HTTPException(
            status_code=404,
            detail="Rental not found"
        )
    return rental