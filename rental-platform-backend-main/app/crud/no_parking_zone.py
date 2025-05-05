from typing import List, Optional
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.no_parking_zone import NoParkingZone
from app.schemas.no_parking_zone import NoParkingZoneCreate, NoParkingZoneUpdate


class CRUDNoParkingZone(
    CRUDBase[NoParkingZone, NoParkingZoneCreate, NoParkingZoneUpdate]
):
    def get_all(
        self, db: Session, *, skip: int = 0, limit: int = 100
    ) -> List[NoParkingZone]:
        """获取所有禁停区"""
        return db.query(NoParkingZone).offset(skip).limit(limit).all()

    def create(self, db: Session, *, obj_in: NoParkingZoneCreate) -> NoParkingZone:
        """创建新的禁停区"""
        # 将Pydantic模型转换为dict，用于数据库存储
        coordinates = [coord.dict() for coord in obj_in.coordinates]

        db_obj = NoParkingZone(
            name=obj_in.name,
            description=obj_in.description,
            coordinates=coordinates,
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def update_zone(
        self, db: Session, *, db_obj: NoParkingZone, obj_in: NoParkingZoneUpdate
    ) -> NoParkingZone:
        """更新禁停区信息"""
        update_data = obj_in.model_dump(exclude_unset=True)

        # 如果更新包含coordinates，需要将Pydantic模型转换为dict
        if "coordinates" in update_data and update_data["coordinates"] is not None:
            update_data["coordinates"] = [
                coord.dict() for coord in update_data["coordinates"]
            ]

        return super().update(db, db_obj=db_obj, obj_in=update_data)

    def delete(self, db: Session, *, zone_id: int) -> Optional[NoParkingZone]:
        """删除禁停区"""
        zone = db.query(NoParkingZone).get(zone_id)
        if zone:
            db.delete(zone)
            db.commit()
            return zone
        return None


no_parking_zone = CRUDNoParkingZone(NoParkingZone)
