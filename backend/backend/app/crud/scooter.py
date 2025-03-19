from typing import Optional, List

from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.scooter import Scooter
from app.schemas.scooter import ScooterCreate, ScooterUpdate


class CRUDScooter(CRUDBase[Scooter, ScooterCreate, ScooterUpdate]):
    def get_multi(self, db: Session) -> List[Scooter]:
        return db.query(Scooter).all()
    
    def create(self, db: Session, *, obj_in: ScooterCreate) -> Scooter:
        db_obj = Scooter(
            model=obj_in.model,
            status=obj_in.status,
            battery_level=obj_in.battery_level,
            location={"lat": 0, "lng": 0} if not obj_in.location else obj_in.location
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj


scooter = CRUDScooter(Scooter)