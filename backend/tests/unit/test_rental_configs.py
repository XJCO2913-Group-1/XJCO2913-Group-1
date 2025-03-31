import pytest
from datetime import datetime
from sqlalchemy.orm import Session
from fastapi import HTTPException

from app.crud.rental_config import rental_config
from app.schemas.rental_config import RentalConfigCreate, RentalConfigUpdate
from app.models.rental_config import RentalConfig

def test_create_rental_config(db: Session):
    # 创建租赁配置
    config_in = RentalConfigCreate(
        base_hourly_rate=20.0,
        period_discounts={
            "1hr": 1.0,
            "4hrs": 0.9,
            "1day": 0.8,
            "1week": 0.7
        },
    )
    
    db_config = rental_config.create_with_deactivate_others(db=db, obj_in=config_in)
    
    assert db_config.base_hourly_rate == config_in.base_hourly_rate
    assert db_config.period_discounts == config_in.period_discounts

def test_get_active_config(db: Session):
    # 创建多个配置，只有一个激活
    config1 = RentalConfigCreate(
        base_hourly_rate=20.0,
        period_discounts={"1hr": 1.0},
    )
    config2 = RentalConfigCreate(
        base_hourly_rate=25.0,
        period_discounts={"1hr": 1.0},
    )
    
    rental_config.create_with_deactivate_others(db=db, obj_in=config1)
    rental_config.create(db=db, obj_in=config2)
    
    active_config = rental_config.get_active_config(db)
    assert active_config is not None
    assert active_config.base_hourly_rate == 20.0
    assert active_config.is_active == True

def test_update_rental_config(db: Session):
    # 创建初始配置
    config_in = RentalConfigCreate(
        base_hourly_rate=20.0,
        period_discounts={"1hr": 1.0},
    )
    db_config = rental_config.create_with_deactivate_others(db=db, obj_in=config_in)
    
    # 更新配置
    update_data = RentalConfigUpdate(
        base_hourly_rate=25.0,
        period_discounts={"1hr": 0.9}
    )
    updated_config = rental_config.update_config(db=db, db_obj=db_config, obj_in=update_data)
    
    assert updated_config.base_hourly_rate == 25.0
    assert updated_config.period_discounts["1hr"] == 0.9
    assert updated_config.is_active == True

def test_deactivate_other_configs(db: Session):
    # 创建多个配置
    configs = [
        RentalConfigCreate(
            base_hourly_rate=rate,
            period_discounts={"1hr": 1.0},
        ) for rate in [20.0, 25.0, 30.0]
    ]
    
    for config in configs:
        rental_config.create_with_deactivate_others(db=db, obj_in=config)
    
    # 验证只有最后一个配置是激活状态
    all_configs = rental_config.get_all_configs(db)
    active_configs = [c for c in all_configs if c.is_active]
    
    assert len(active_configs) == 1
    assert active_configs[0].base_hourly_rate == 30.0