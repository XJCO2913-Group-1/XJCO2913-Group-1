from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import crud, models
from app.api import deps
from app.schemas.no_parking_zone import (
    NoParkingZone,
    NoParkingZoneCreate,
    NoParkingZoneUpdate,
)

router = APIRouter()


@router.get("/", response_model=List[NoParkingZone])
async def read_no_parking_zones(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """
    获取所有禁停区列表
    """
    zones = crud.no_parking_zone.get_all(db, skip=skip, limit=limit)
    return zones


@router.post("/", response_model=NoParkingZone, status_code=status.HTTP_201_CREATED)
async def create_no_parking_zone(
    *,
    db: Session = Depends(deps.get_db),
    zone_in: NoParkingZoneCreate,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    创建新的禁停区
    """
    # 可以在这里添加权限检查，例如只允许管理员创建禁停区
    zone = crud.no_parking_zone.create(db=db, obj_in=zone_in)
    return zone


@router.get("/{zone_id}", response_model=NoParkingZone)
async def read_no_parking_zone(
    *,
    db: Session = Depends(deps.get_db),
    zone_id: int,
) -> Any:
    """
    通过ID获取禁停区
    """
    zone = crud.no_parking_zone.get(db=db, id=zone_id)
    if not zone:
        raise HTTPException(status_code=404, detail="No parking zone not found")
    return zone


@router.put("/{zone_id}", response_model=NoParkingZone)
async def update_no_parking_zone(
    *,
    db: Session = Depends(deps.get_db),
    zone_id: int,
    zone_in: NoParkingZoneUpdate,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    更新禁停区
    """
    zone = crud.no_parking_zone.get(db=db, id=zone_id)
    if not zone:
        raise HTTPException(status_code=404, detail="No parking zone not found")

    # 可以在这里添加权限检查，例如只允许管理员更新禁停区
    zone = crud.no_parking_zone.update_zone(db=db, db_obj=zone, obj_in=zone_in)
    return zone


@router.delete("/{zone_id}", response_model=NoParkingZone)
async def delete_no_parking_zone(
    *,
    db: Session = Depends(deps.get_db),
    zone_id: int,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    删除禁停区
    """
    zone = crud.no_parking_zone.get(db=db, id=zone_id)
    if not zone:
        raise HTTPException(status_code=404, detail="No parking zone not found")

    # 可以在这里添加权限检查，例如只允许管理员删除禁停区
    zone = crud.no_parking_zone.delete(db=db, zone_id=zone_id)
    return zone
