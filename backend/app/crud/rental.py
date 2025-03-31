from typing import List, Optional
from datetime import datetime, timedelta
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.rental import Rental
from app.schemas.rental import RentalCreate, RentalUpdate
from app.models.scooter import Scooter
from app.schemas.scooter import ScooterStatus
from app.schemas.rental import RentalStatus

class CRUDRental(CRUDBase[Rental, RentalCreate, RentalUpdate]):
    def get_user_rentals(self, db: Session, *, user_id: int) -> List[Rental]:
        return db.query(Rental).filter(Rental.user_id == user_id).all()

    def get_active_rentals(self, db: Session) -> List[Rental]:
        return db.query(Rental).filter(Rental.status == RentalStatus.ACTIVE).all()
    
    def check_expired_rentals(self, db: Session):
        now = datetime.utcnow()
        expired_rentals = db.query(Rental).filter(
            Rental.status == RentalStatus.ACTIVE,
            Rental.start_time <= now - timedelta(hours=1)
        ).all()
        
        for rental in expired_rentals:
            rental.status = RentalStatus.COMPLETED
            rental.end_time = now
            db.add(rental)
            scooter = db.query(Scooter).filter(Scooter.id == rental.scooter_id).first()
            if scooter:
                scooter.status = ScooterStatus.AVAILABLE
                db.add(scooter)
        db.commit()
    
    def create_with_scooter(self, db: Session, *, rental_in: RentalCreate, start_time: datetime, user_id: int, cost: float) -> Rental:
        scooter = db.query(Scooter).filter(Scooter.id == rental_in.scooter_id).first()
        if scooter:
            scooter.status = ScooterStatus.IN_USE
            db.add(scooter)
        
        # 创建租赁记录
        rental = Rental(
            user_id=user_id,
            scooter_id=rental_in.scooter_id,
            start_time=start_time,
            end_time=rental_in.end_time,
            status=rental_in.status,
            cost=cost
        )
        db.add(rental)
        db.commit()
        db.refresh(rental)
        return rental
    
    def get_by_id(self, db: Session, rental_id: int) -> Optional[Rental]:
        return db.query(Rental).filter(Rental.id == rental_id).first()
    
    def update_rental(self, db: Session, *, rental: Rental, rental_in: RentalUpdate) -> Rental:
        # 状态转换验证
        if rental_in.status:
            allowed_transitions = {
                RentalStatus.ACTIVE: [RentalStatus.COMPLETED],
                RentalStatus.COMPLETED: [],
                RentalStatus.CANCELLED: []
            }
            if rental_in.status not in allowed_transitions[rental.status]:
                from fastapi import HTTPException
                raise HTTPException(status_code=400, detail="非法状态转换")

        update_data = rental_in.model_dump(exclude_unset=True)
        return super().update(db, db_obj=rental, obj_in=update_data)
    
    def update_rental_status(self, db: Session, *, rental: Rental, status: RentalStatus) -> Rental:
        rental.status = status
        db.add(rental)
        db.commit()
    
    def delete_rental(self, db: Session, *, rental_id: int) -> Optional[Rental]:
        rental = self.get_by_id(db, rental_id)
        if rental:
            db.delete(rental)
            db.commit()
        return rental


rental = CRUDRental(Rental)