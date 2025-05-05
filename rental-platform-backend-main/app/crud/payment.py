from typing import List, Optional
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.payment import Payment, PaymentStatus
from app.schemas.payment import PaymentCreate, PaymentUpdate


class CRUDPayment(CRUDBase[Payment, PaymentCreate, PaymentUpdate]):
    def create_with_user_and_rental(
        self, db: Session, *, obj_in: PaymentCreate, user_id: int
    ) -> Payment:
        """
        创建支付记录
        """
        db_obj = Payment(
            user_id=user_id,
            rental_id=obj_in.rental_id,
            payment_card_id=obj_in.payment_card_id,
            amount=obj_in.amount,
            currency=obj_in.currency,
            status=obj_in.status or PaymentStatus.PENDING,
            payment_method=obj_in.payment_method,
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_by_rental(self, db: Session, *, rental_id: int) -> List[Payment]:
        """
        获取租赁的所有支付记录
        """
        return db.query(Payment).filter(Payment.rental_id == rental_id).all()

    def get_by_user(
        self, db: Session, *, user_id: int, skip: int = 0, limit: int = 100
    ) -> List[Payment]:
        """
        获取用户的所有支付记录
        """
        return (
            db.query(Payment)
            .filter(Payment.user_id == user_id)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_by_id_and_user(
        self, db: Session, *, id: int, user_id: int
    ) -> Optional[Payment]:
        """
        根据ID和用户ID获取支付记录
        """
        return (
            db.query(Payment)
            .filter(Payment.id == id, Payment.user_id == user_id)
            .first()
        )

    def update_payment_status(
        self,
        db: Session,
        *,
        db_obj: Payment,
        status: PaymentStatus,
        transaction_id: Optional[str] = None,
    ) -> Payment:
        """
        更新支付状态
        """
        update_data = {"status": status}
        if transaction_id:
            update_data["transaction_id"] = transaction_id

        return super().update(db, db_obj=db_obj, obj_in=update_data)


payment = CRUDPayment(Payment)
