from typing import List, Optional, Dict, Any, Union
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.payment_card import PaymentCard
from app.schemas.payment_card import PaymentCardCreate, PaymentCardUpdate
from app.core.payment import encrypt_card_data, get_card_type


class CRUDPaymentCard(CRUDBase[PaymentCard, PaymentCardCreate, PaymentCardUpdate]):
    def create_with_user(self, db: Session, *, obj_in: PaymentCardCreate, user_id: int) -> PaymentCard:
        """
        创建用户的支付卡
        """
        # 获取卡类型
        card_type = get_card_type(obj_in.card_number)
        
        # 加密敏感数据
        encrypted_card_number = encrypt_card_data(obj_in.card_number)
        encrypted_cvv = encrypt_card_data(obj_in.cvv)
        
        # 获取卡号后四位
        card_number_last4 = obj_in.card_number[-4:]
        
        # 创建数据库对象
        db_obj = PaymentCard(
            user_id=user_id,
            card_holder_name=obj_in.card_holder_name,
            card_number_last4=card_number_last4,
            encrypted_card_number=encrypted_card_number,
            card_expiry_month=obj_in.card_expiry_month,
            card_expiry_year=obj_in.card_expiry_year,
            encrypted_cvv=encrypted_cvv,
            card_type=card_type,
            is_default=obj_in.is_default
        )
        
        # 如果这是用户的第一张卡，或者设置为默认卡，则需要更新其他卡的默认状态
        if obj_in.is_default:
            # 将用户的所有其他卡设置为非默认
            db.query(PaymentCard).filter(
                PaymentCard.user_id == user_id,
                PaymentCard.id != db_obj.id  # 排除当前卡
            ).update({PaymentCard.is_default: False})
        
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj
    
    def get_by_user(self, db: Session, *, user_id: int, skip: int = 0, limit: int = 100) -> List[PaymentCard]:
        """
        获取用户的所有支付卡
        """
        return db.query(PaymentCard).filter(PaymentCard.user_id == user_id).offset(skip).limit(limit).all()
    
    def get_by_id_and_user(self, db: Session, *, id: int, user_id: int) -> Optional[PaymentCard]:
        """
        根据ID和用户ID获取支付卡
        """
        return db.query(PaymentCard).filter(PaymentCard.id == id, PaymentCard.user_id == user_id).first()
    
    def get_default_card(self, db: Session, *, user_id: int) -> Optional[PaymentCard]:
        """
        获取用户的默认支付卡
        """
        return db.query(PaymentCard).filter(PaymentCard.user_id == user_id, PaymentCard.is_default == True).first()
    
    def update_card(self, db: Session, *, db_obj: PaymentCard, obj_in: Union[PaymentCardUpdate, Dict[str, Any]]) -> PaymentCard:
        """
        更新支付卡信息
        """
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.model_dump(exclude_unset=True)
        
        # 如果更新包含设置为默认卡
        if update_data.get("is_default", False):
            # 将用户的所有其他卡设置为非默认
            db.query(PaymentCard).filter(
                PaymentCard.user_id == db_obj.user_id,
                PaymentCard.id != db_obj.id  # 排除当前卡
            ).update({PaymentCard.is_default: False})
        
        return super().update(db, db_obj=db_obj, obj_in=update_data)
    
    def delete_by_id_and_user(self, db: Session, *, id: int, user_id: int) -> Optional[PaymentCard]:
        """
        根据ID和用户ID删除支付卡
        """
        obj = db.query(PaymentCard).filter(PaymentCard.id == id, PaymentCard.user_id == user_id).first()
        if not obj:
            return None
        
        # 如果删除的是默认卡，则将用户的第一张卡设为默认（如果有的话）
        if obj.is_default:
            # 查找用户的其他卡
            other_card = db.query(PaymentCard).filter(
                PaymentCard.user_id == user_id,
                PaymentCard.id != id
            ).first()
            
            if other_card:
                other_card.is_default = True
                db.add(other_card)
        
        db.delete(obj)
        db.commit()
        return obj


payment_card = CRUDPaymentCard(PaymentCard)