from typing import Any, List
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps
from app.schemas.rental import Rental, RentalCreate, RentalUpdate, RentalPeriod
from app.api.deps import get_db
from app.core.email import send_rental_confirmation

router = APIRouter()

# 租赁时长对应的小时数
RENTAL_PERIOD_HOURS = {
    RentalPeriod.ONE_HOUR: 1,
    RentalPeriod.FOUR_HOURS: 4,
    RentalPeriod.ONE_DAY: 24,
    RentalPeriod.ONE_WEEK: 168
}

def calculate_rental_cost(db: Session, rental_period: RentalPeriod) -> float:
    # 获取当前生效的租赁配置
    config = crud.rental_config.get_active_config(db)
    if not config:
        raise HTTPException(
            status_code=500,
            detail="No active rental configuration found"
        )
    
    hours = RENTAL_PERIOD_HOURS[rental_period]
    base_cost = hours * config.base_hourly_rate
    
    # 从配置中获取对应时段的折扣率
    discount = config.period_discounts.get(rental_period.value, 1.0)
    
    return base_cost * discount


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
    start_time = datetime.now()
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
    rental_cost = calculate_rental_cost(db, rental_in.rental_period)
    end_time = start_time + timedelta(hours=RENTAL_PERIOD_HOURS[rental_in.rental_period])
    rental_in.end_time = end_time
    
    # 创建租赁记录并更新滑板车状态
    rental = crud.rental.create_with_scooter(
        db=db,
        rental_in=rental_in,
        start_time=start_time,
        user_id=current_user.id,
        cost=rental_cost
    )

    # # 发送租赁确认邮件
    # rental_info = {
    #     "id": rental.id,
    #     "scooter_id": rental.scooter_id,
    #     "start_time": rental.start_time.strftime("%Y-%m-%d %H:%M:%S"),
    #     "end_time": rental.end_time.strftime("%Y-%m-%d %H:%M:%S"),
    #     "total_cost": rental.cost
    # }
    # await send_rental_confirmation(current_user.email, rental_info)

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


@router.patch("/{rental_id}", response_model=Rental)
async def update_rental_status(
    rental_id: int,
    rental_in: RentalUpdate,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_user)
) -> Any:
    """更新租赁状态"""
    db_rental = crud.rental.get(db, id=rental_id)
    if not db_rental:
        raise HTTPException(status_code=404, detail="Rental not found")
    
    if db_rental.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    updated_rental = crud.rental.update_rental(db, rental=db_rental, rental_in=rental_in)
    return updated_rental


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


@router.post("/{rental_id}/end", response_model=Rental)
async def end_rental(
    rental_id: int,
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_user)
) -> Any:
    """结束租赁"""
    # 获取租赁记录
    rental = crud.rental.get(db, id=rental_id)
    if not rental:
        raise HTTPException(status_code=404, detail="Rental not found")
    
    # 验证用户权限
    if rental.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    # 检查租赁状态
    if rental.status != "active":
        raise HTTPException(status_code=400, detail="Rental is not active")
    
    # 更新租赁状态为已完成
    rental_update = RentalUpdate(status="completed")
    updated_rental = crud.rental.update_rental(db, rental=rental, rental_in=rental_update)
    
    # 更新滑板车状态为可用
    scooter = crud.scooter.get(db, id=rental.scooter_id)
    if scooter:
        crud.scooter.update(db, db_obj=scooter, obj_in={"status": "available"})
    
    return updated_rental


