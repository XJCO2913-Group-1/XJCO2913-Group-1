import pytest
from sqlalchemy.orm import Session
from fastapi import HTTPException

from app.crud.payment_card import payment_card
from app.schemas.payment_card import PaymentCardCreate, PaymentCardUpdate
from app.models.payment_card import PaymentCard
from app.core.payment import encrypt_card_data, decrypt_card_data


def test_create_payment_card(db: Session):
    """测试创建支付卡"""
    card_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="4111111111111111",
        card_expiry_month="12",
        card_expiry_year="25",
        cvv="123",
        is_default=True
    )
    db_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)
    
    assert db_card.card_holder_name == card_in.card_holder_name
    assert db_card.card_number_last4 == card_in.card_number[-4:]
    assert db_card.card_expiry_month == card_in.card_expiry_month
    assert db_card.card_expiry_year == card_in.card_expiry_year
    assert db_card.is_default == True
    assert db_card.card_type == "Visa"
    
    # 验证卡号和CVV已加密
    assert db_card.encrypted_card_number != card_in.card_number
    assert db_card.encrypted_cvv != card_in.cvv
    
    # 验证可以解密
    assert decrypt_card_data(db_card.encrypted_card_number) == card_in.card_number
    assert decrypt_card_data(db_card.encrypted_cvv) == card_in.cvv


def test_create_multiple_cards_default_handling(db: Session):
    """测试创建多张卡时的默认卡处理"""
    # 创建第一张卡（默认卡）
    card1_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="4111111111111111",
        card_expiry_month="12",
        card_expiry_year="25",
        cvv="123",
        is_default=True
    )
    card1 = payment_card.create_with_user(db=db, obj_in=card1_in, user_id=1)
    assert card1.is_default == True
    
    # 创建第二张卡（设为默认）
    card2_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="5555555555554444",
        card_expiry_month="10",
        card_expiry_year="24",
        cvv="456",
        is_default=True
    )
    card2 = payment_card.create_with_user(db=db, obj_in=card2_in, user_id=1)
    assert card2.is_default == True
    
    # 验证第一张卡不再是默认卡
    db.refresh(card1)
    assert card1.is_default == False
    
    # 创建第三张卡（不设为默认）
    card3_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="378282246310005",
        card_expiry_month="09",
        card_expiry_year="23",
        cvv="1234",
        is_default=False
    )
    card3 = payment_card.create_with_user(db=db, obj_in=card3_in, user_id=1)
    assert card3.is_default == False
    
    # 验证第二张卡仍然是默认卡
    db.refresh(card2)
    assert card2.is_default == True


def test_get_payment_cards_by_user(db: Session):
    """测试获取用户的所有支付卡"""
    # 创建测试卡
    card_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="4111111111111111",
        card_expiry_month="12",
        card_expiry_year="25",
        cvv="123",
        is_default=True
    )
    payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)
    
    # 获取用户的卡
    cards = payment_card.get_by_user(db=db, user_id=1)
    assert len(cards) >= 1
    assert all(card.user_id == 1 for card in cards)


def test_get_payment_card_by_id_and_user(db: Session):
    """测试通过ID和用户ID获取支付卡"""
    # 创建测试卡
    card_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="4111111111111111",
        card_expiry_month="12",
        card_expiry_year="25",
        cvv="123",
        is_default=True
    )
    created_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)
    
    # 获取卡
    fetched_card = payment_card.get_by_id_and_user(db=db, id=created_card.id, user_id=1)
    assert fetched_card is not None
    assert fetched_card.id == created_card.id
    assert fetched_card.user_id == 1
    
    # 尝试获取不存在的卡
    non_existent_card = payment_card.get_by_id_and_user(db=db, id=9999, user_id=1)
    assert non_existent_card is None
    
    # 尝试获取属于其他用户的卡
    other_user_card = payment_card.get_by_id_and_user(db=db, id=created_card.id, user_id=2)
    assert other_user_card is None


def test_get_default_card(db: Session):
    """测试获取用户的默认支付卡"""
    # 创建默认卡
    card_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="4111111111111111",
        card_expiry_month="12",
        card_expiry_year="25",
        cvv="123",
        is_default=True
    )
    created_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)
    
    # 获取默认卡
    default_card = payment_card.get_default_card(db=db, user_id=1)
    assert default_card is not None
    assert default_card.id == created_card.id
    assert default_card.is_default == True


def test_update_payment_card(db: Session):
    """测试更新支付卡"""
    # 创建测试卡
    card_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="4111111111111111",
        card_expiry_month="12",
        card_expiry_year="25",
        cvv="123",
        is_default=False
    )
    created_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)
    
    # 更新卡信息
    card_update = PaymentCardUpdate(
        card_holder_name="Updated User",
        card_expiry_month="11",
        is_default=True
    )
    updated_card = payment_card.update_card(db=db, db_obj=created_card, obj_in=card_update)
    
    assert updated_card.card_holder_name == "Updated User"
    assert updated_card.card_expiry_month == "11"
    assert updated_card.is_default == True
    
    # 验证其他字段未变
    assert updated_card.card_number_last4 == created_card.card_number_last4
    assert updated_card.card_expiry_year == created_card.card_expiry_year
    assert updated_card.encrypted_cvv == created_card.encrypted_cvv


def test_delete_payment_card(db: Session):
    """测试删除支付卡"""
    # 创建测试卡
    card_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="4111111111111111",
        card_expiry_month="12",
        card_expiry_year="25",
        cvv="123",
        is_default=True
    )
    created_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)
    
    # 删除卡
    deleted_card = payment_card.delete_by_id_and_user(db=db, id=created_card.id, user_id=1)
    assert deleted_card is not None
    assert deleted_card.id == created_card.id
    
    # 验证卡已被删除
    fetched_card = payment_card.get_by_id_and_user(db=db, id=created_card.id, user_id=1)
    assert fetched_card is None
    
    # 尝试删除不存在的卡
    non_existent_card = payment_card.delete_by_id_and_user(db=db, id=9999, user_id=1)
    assert non_existent_card is None
    
    # 尝试删除属于其他用户的卡
    card_in2 = PaymentCardCreate(
        card_holder_name="Other User",
        card_number="5555555555554444",
        card_expiry_month="10",
        card_expiry_year="24",
        cvv="456",
        is_default=True
    )
    other_card = payment_card.create_with_user(db=db, obj_in=card_in2, user_id=2)
    
    wrong_user_delete = payment_card.delete_by_id_and_user(db=db, id=other_card.id, user_id=1)
    assert wrong_user_delete is None
    
    # 验证其他用户的卡未被删除
    other_card_check = payment_card.get_by_id_and_user(db=db, id=other_card.id, user_id=2)
    assert other_card_check is not None