import pytest
from sqlalchemy.orm import Session
from datetime import datetime

from app.crud.payment import payment
from app.schemas.payment import PaymentCreate, PaymentUpdate
from app.models.payment import Payment, PaymentStatus, PaymentMethod
from app.core.payment import process_payment


def test_create_payment(db: Session):
    """测试创建支付记录"""
    payment_in = PaymentCreate(
        rental_id=1,
        amount=100.0,
        currency="CNY",
        payment_method=PaymentMethod.CARD,
        status=PaymentStatus.PENDING
    )
    db_payment = payment.create_with_user_and_rental(db=db, obj_in=payment_in, user_id=1)
    
    assert db_payment.rental_id == payment_in.rental_id
    assert db_payment.amount == payment_in.amount
    assert db_payment.currency == payment_in.currency
    assert db_payment.payment_method == payment_in.payment_method
    assert db_payment.status == payment_in.status
    assert db_payment.user_id == 1
    assert db_payment.created_at is not None


def test_create_payment_with_saved_card(db: Session):
    """测试使用已保存的卡创建支付记录"""
    payment_in = PaymentCreate(
        rental_id=1,
        amount=100.0,
        currency="CNY",
        payment_method=PaymentMethod.SAVED_CARD,
        payment_card_id=1,
        status=PaymentStatus.PENDING
    )
    db_payment = payment.create_with_user_and_rental(db=db, obj_in=payment_in, user_id=1)
    
    assert db_payment.rental_id == payment_in.rental_id
    assert db_payment.payment_card_id == payment_in.payment_card_id
    assert db_payment.payment_method == PaymentMethod.SAVED_CARD


def test_get_payments_by_user(db: Session):
    """测试获取用户的所有支付记录"""
    # 创建测试支付记录
    payment_in = PaymentCreate(
        rental_id=1,
        amount=100.0,
        currency="CNY",
        payment_method=PaymentMethod.CARD,
        status=PaymentStatus.PENDING
    )
    payment.create_with_user_and_rental(db=db, obj_in=payment_in, user_id=1)
    
    # 获取用户的支付记录
    payments = payment.get_by_user(db=db, user_id=1)
    assert len(payments) >= 1
    assert all(p.user_id == 1 for p in payments)


def test_get_payments_by_rental(db: Session):
    """测试获取租赁的所有支付记录"""
    # 创建测试支付记录
    payment_in = PaymentCreate(
        rental_id=1,
        amount=100.0,
        currency="CNY",
        payment_method=PaymentMethod.CARD,
        status=PaymentStatus.PENDING
    )
    payment.create_with_user_and_rental(db=db, obj_in=payment_in, user_id=1)
    
    # 获取租赁的支付记录
    payments = payment.get_by_rental(db=db, rental_id=1)
    assert len(payments) >= 1
    assert all(p.rental_id == 1 for p in payments)


def test_get_payment_by_id_and_user(db: Session):
    """测试通过ID和用户ID获取支付记录"""
    # 创建测试支付记录
    payment_in = PaymentCreate(
        rental_id=1,
        amount=100.0,
        currency="CNY",
        payment_method=PaymentMethod.CARD,
        status=PaymentStatus.PENDING
    )
    created_payment = payment.create_with_user_and_rental(db=db, obj_in=payment_in, user_id=1)
    
    # 获取支付记录
    fetched_payment = payment.get_by_id_and_user(db=db, id=created_payment.id, user_id=1)
    assert fetched_payment is not None
    assert fetched_payment.id == created_payment.id
    assert fetched_payment.user_id == 1
    
    # 尝试获取不存在的支付记录
    non_existent_payment = payment.get_by_id_and_user(db=db, id=9999, user_id=1)
    assert non_existent_payment is None
    
    # 尝试获取属于其他用户的支付记录
    other_payment_in = PaymentCreate(
        rental_id=2,
        amount=200.0,
        currency="CNY",
        payment_method=PaymentMethod.CARD,
        status=PaymentStatus.PENDING
    )
    other_payment = payment.create_with_user_and_rental(db=db, obj_in=other_payment_in, user_id=2)
    
    wrong_user_payment = payment.get_by_id_and_user(db=db, id=other_payment.id, user_id=1)
    assert wrong_user_payment is None


def test_update_payment_status(db: Session):
    """测试更新支付状态"""
    # 创建测试支付记录
    payment_in = PaymentCreate(
        rental_id=1,
        amount=100.0,
        currency="CNY",
        payment_method=PaymentMethod.CARD,
        status=PaymentStatus.PENDING
    )
    created_payment = payment.create_with_user_and_rental(db=db, obj_in=payment_in, user_id=1)
    
    # 更新支付状态
    updated_payment = payment.update_payment_status(
        db=db,
        db_obj=created_payment,
        status=PaymentStatus.COMPLETED,
        transaction_id="txn_123456"
    )
    
    assert updated_payment.status == PaymentStatus.COMPLETED
    assert updated_payment.transaction_id == "txn_123456"
    
    # 验证其他字段未变
    assert updated_payment.rental_id == created_payment.rental_id
    assert updated_payment.amount == created_payment.amount
    assert updated_payment.payment_method == created_payment.payment_method


def test_process_payment_function():
    """测试支付处理函数"""
    # 测试成功的支付
    card_data = {
        "card_number": "4111111111111111",
        "card_expiry_month": "12",
        "card_expiry_year": "25",
        "cvv": "123"
    }
    result = process_payment(amount=100.0, card_data=card_data)
    
    assert result["success"] is True
    assert "transaction_id" in result
    assert result["status"] == PaymentStatus.COMPLETED
    
    # 测试使用已保存的卡支付
    saved_card_result = process_payment(amount=100.0, saved_card_id=1)
    
    assert saved_card_result["success"] is True
    assert "transaction_id" in saved_card_result
    assert saved_card_result["status"] == PaymentStatus.COMPLETED
    
    # 测试金额为0的支付（应该失败）
    zero_amount_result = process_payment(amount=0.0, card_data=card_data)
    
    assert zero_amount_result["success"] is False
    assert zero_amount_result["status"] == PaymentStatus.FAILED