from typing import List, Optional
from datetime import datetime
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.rental import Rental
from app.schemas.rental import RentalCreate, RentalUpdate
from app.models.scooter import Scooter


class CRUDRental(CRUDBase[Rental, RentalCreate, RentalUpdate]):
    def get_user_rentals(self, db: Session, *, user_id: int) -> List[Rental]:
        return db.query(Rental).filter(Rental.user_id == user_id).all()

    def get_active_rentals(self, db: Session) -> List[Rental]:
        return db.query(Rental).filter(Rental.status == "active").all()
    
    def create_with_scooter(self, db: Session, *, rental_in: RentalCreate, user_id: int, total_cost: float) -> Rental:
        # 更新滑板车状态
        scooter = db.query(Scooter).filter(Scooter.id == rental_in.scooter_id).first()
        if scooter:
            scooter.status = "in_use"
            db.add(scooter)
        
        # 创建租赁记录
        rental = Rental(
            user_id=user_id,
            scooter_id=rental_in.scooter_id,
            start_time=rental_in.start_time,
            end_time=rental_in.end_time,
            status=rental_in.status,
            total_cost=total_cost,
            start_location=rental_in.start_location
        )
        db.add(rental)
        db.commit()
        db.refresh(rental)
        return rental
    
    def get_by_id(self, db: Session, rental_id: int) -> Optional[Rental]:
        return db.query(Rental).filter(Rental.id == rental_id).first()
    
    def update_rental(self, db: Session, *, rental: Rental, rental_in: RentalUpdate) -> Rental:
        update_data = rental_in.model_dump(exclude_unset=True)
        return super().update(db, db_obj=rental, obj_in=update_data)
    
    def delete_rental(self, db: Session, *, rental_id: int) -> Optional[Rental]:
        rental = self.get_by_id(db, rental_id)
        if rental:
            db.delete(rental)
            db.commit()
        return rental


rental = CRUDRental(Rental)