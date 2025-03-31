from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import crud, schemas
from app.api import deps
from app.schemas.rental_config import RentalConfig, RentalConfigCreate, RentalConfigUpdate

router = APIRouter()

@router.get("/", response_model=List[RentalConfig])
async def read_rental_configs(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """获取所有租赁配置列表"""
    configs = crud.rental_config.get_all_configs(db, skip=skip, limit=limit)
    return configs

@router.get("/active", response_model=RentalConfig)
async def get_active_config(db: Session = Depends(deps.get_db)) -> Any:
    """获取当前生效的租赁配置"""
    config = crud.rental_config.get_active_config(db)
    if not config:
        raise HTTPException(
            status_code=404,
            detail="No active rental configuration found"
        )
    return config

@router.post("/", response_model=RentalConfig, status_code=status.HTTP_201_CREATED)
async def create_rental_config(
    config_in: RentalConfigCreate,
    db: Session = Depends(deps.get_db),
) -> Any:
    """创建新的租赁配置（会自动停用其他配置）"""
    config = crud.rental_config.create_with_deactivate_others(db, obj_in=config_in)
    return config

@router.put("/{config_id}", response_model=RentalConfig)
async def update_rental_config(
    config_id: int,
    config_in: RentalConfigUpdate,
    db: Session = Depends(deps.get_db),
) -> Any:
    """更新租赁配置"""
    config = crud.rental_config.get(db, id=config_id)
    if not config:
        raise HTTPException(
            status_code=404,
            detail="Configuration not found"
        )
    config = crud.rental_config.update_config(db, db_obj=config, obj_in=config_in)
    return config