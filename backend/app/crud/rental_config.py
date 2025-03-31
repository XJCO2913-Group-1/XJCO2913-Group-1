from typing import List, Optional
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.rental_config import RentalConfig
from app.schemas.rental_config import RentalConfigCreate, RentalConfigUpdate

class CRUDRentalConfig(CRUDBase[RentalConfig, RentalConfigCreate, RentalConfigUpdate]):
    def get_active_config(self, db: Session) -> Optional[RentalConfig]:
        return db.query(RentalConfig).filter(RentalConfig.is_active == 1).first()
    
    def create_with_deactivate_others(self, db: Session, *, obj_in: RentalConfigCreate) -> RentalConfig:
        # 将其他配置设置为非活动
        db.query(RentalConfig).update({RentalConfig.is_active: 0})
        
        db_obj = RentalConfig(
            base_hourly_rate=obj_in.base_hourly_rate,
            period_discounts=obj_in.period_discounts,
            description=obj_in.description,
            is_active=1
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj
    
    def update_config(self, db: Session, *, db_obj: RentalConfig, obj_in: RentalConfigUpdate) -> RentalConfig:
        update_data = obj_in.model_dump(exclude_unset=True)
        return super().update(db, db_obj=db_obj, obj_in=update_data)
    
    def get_all_configs(self, db: Session, *, skip: int = 0, limit: int = 100) -> List[RentalConfig]:
        return db.query(RentalConfig).offset(skip).limit(limit).all()

rental_config = CRUDRentalConfig(RentalConfig)