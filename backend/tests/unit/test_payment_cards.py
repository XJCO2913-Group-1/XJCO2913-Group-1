from sqlalchemy.orm import Session

from app.crud.payment_card import payment_card
from app.schemas.payment_card import PaymentCardCreate, PaymentCardUpdate
from app.core.payment import decrypt_card_data


def test_create_payment_card(db: Session):
    """测试创建支付卡"""
    card_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="4111111111111111",
        card_expiry_month="12",
        card_expiry_year="25",
        cvv="123",
        is_default=True,
    )
    db_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)

    assert db_card.card_holder_name == card_in.card_holder_name
    assert db_card.card_number_last4 == card_in.card_number[-4:]
    assert db_card.card_expiry_month == card_in.card_expiry_month
    assert db_card.card_expiry_year == card_in.card_expiry_year
    assert db_card.is_default is True
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
        is_default=True,
    )
    card1 = payment_card.create_with_user(db=db, obj_in=card1_in, user_id=1)
    assert card1.is_default is True

    # 创建第二张卡（设为默认）
    card2_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="5555555555554444",
        card_expiry_month="10",
        card_expiry_year="24",
        cvv="456",
        is_default=True,
    )
    card2 = payment_card.create_with_user(db=db, obj_in=card2_in, user_id=1)
    assert card2.is_default is True

    # 验证第一张卡不再是默认卡
    db.refresh(card1)
    assert card1.is_default is False

    # 创建第三张卡（不设为默认）
    card3_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="378282246310005",
        card_expiry_month="09",
        card_expiry_year="23",
        cvv="1234",
        is_default=False,
    )
    card3 = payment_card.create_with_user(db=db, obj_in=card3_in, user_id=1)
    assert card3.is_default is False

    # 验证第二张卡仍然是默认卡
    db.refresh(card2)
    assert card2.is_default is True


def test_get_payment_cards_by_user(db: Session):
    """测试获取用户的所有支付卡"""
    # 创建测试卡
    card_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="4111111111111111",
        card_expiry_month="12",
        card_expiry_year="25",
        cvv="123",
        is_default=True,
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
        is_default=True,
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
    other_user_card = payment_card.get_by_id_and_user(
        db=db, id=created_card.id, user_id=2
    )
    assert other_user_card is None


def test_update_payment_card(db: Session):
    """测试更新支付卡"""
    # 创建测试卡
    card_in = PaymentCardCreate(
        card_holder_name="Test User",
        card_number="4111111111111111",
        card_expiry_month="12",
        card_expiry_year="25",
        cvv="123",
        is_default=False,
    )
    created_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)

    # 更新卡信息
    card_update = PaymentCardUpdate(
        card_holder_name="Updated User", card_expiry_month="11", is_default=True
    )
    updated_card = payment_card.update_card(
        db=db, db_obj=created_card, obj_in=card_update
    )

    assert updated_card.card_holder_name == "Updated User"
    assert updated_card.card_expiry_month == "11"
    assert updated_card.is_default is True

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
        is_default=True,
    )
    created_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)

    # 删除卡
    deleted_card = payment_card.delete_by_id_and_user(
        db=db, id=created_card.id, user_id=1
    )
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
        is_default=True,
    )
    def test_get_default_card(db: Session):
        """测试获取用户的默认卡"""
        # 创建默认卡
        card_in = PaymentCardCreate(
            card_holder_name="Default User",
            card_number="4111111111111111",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
            is_default=True,
        )
        created_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)

        # 获取默认卡
        default_card = payment_card.get_default_card(db=db, user_id=1)
        assert default_card is not None
        assert default_card.id == created_card.id
        assert default_card.is_default is True


    def test_set_card_as_default(db: Session):
        """测试将一张卡设为默认卡"""
        # 创建两张卡
        card1_in = PaymentCardCreate(
            card_holder_name="Test User 1",
            card_number="4111111111111111",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
            is_default=True,
        )
        card1 = payment_card.create_with_user(db=db, obj_in=card1_in, user_id=1)
        
        card2_in = PaymentCardCreate(
            card_holder_name="Test User 2",
            card_number="5555555555554444",
            card_expiry_month="10",
            card_expiry_year="24",
            cvv="456",
            is_default=False,
        )
        card2 = payment_card.create_with_user(db=db, obj_in=card2_in, user_id=1)
        
        # 设置第二张卡为默认卡
        card2 = payment_card.set_default_card(db=db, card=card2)
        assert card2.is_default is True
        
        # 验证第一张卡不再是默认卡
        db.refresh(card1)
        assert card1.is_default is False


    def test_create_card_without_default_flag(db: Session):
        """测试不指定默认状态创建卡片"""
        # 清除用户1的所有卡片
        cards = payment_card.get_by_user(db=db, user_id=1)
        for card in cards:
            payment_card.delete_by_id_and_user(db=db, id=card.id, user_id=1)
        
        # 创建不指定默认状态的卡片（首张卡）
        card_in = PaymentCardCreate(
            card_holder_name="Test User",
            card_number="4111111111111111",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
        )
        card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)
        assert card.is_default is True  # 首张卡应自动成为默认卡


    def test_different_card_types(db: Session):
        """测试不同类型的卡"""
        # Visa
        visa_card = PaymentCardCreate(
            card_holder_name="Visa User",
            card_number="4111111111111111",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
        )
        visa_db = payment_card.create_with_user(db=db, obj_in=visa_card, user_id=1)
        assert visa_db.card_type == "Visa"
        
        # MasterCard
        mc_card = PaymentCardCreate(
            card_holder_name="MC User",
            card_number="5555555555554444",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
        )
        mc_db = payment_card.create_with_user(db=db, obj_in=mc_card, user_id=1)
        assert mc_db.card_type == "MasterCard"
        
        # Amex
        amex_card = PaymentCardCreate(
            card_holder_name="Amex User",
            card_number="378282246310005",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="1234",
        )
        amex_db = payment_card.create_with_user(db=db, obj_in=amex_card, user_id=1)
        assert amex_db.card_type == "American Express"


    def test_update_card_holder_name(db: Session):
        """测试更新卡持有人姓名"""
        card_in = PaymentCardCreate(
            card_holder_name="Original Name",
            card_number="4111111111111111",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
        )
        created_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)
        
        # 只更新持卡人姓名
        card_update = PaymentCardUpdate(card_holder_name="New Name")
        updated_card = payment_card.update_card(db=db, db_obj=created_card, obj_in=card_update)
        
        assert updated_card.card_holder_name == "New Name"
        assert updated_card.card_expiry_month == created_card.card_expiry_month
        assert updated_card.card_expiry_year == created_card.card_expiry_year
        assert updated_card.is_default == created_card.is_default


    def test_update_card_expiry_date(db: Session):
        """测试更新卡有效期"""
        card_in = PaymentCardCreate(
            card_holder_name="Test User",
            card_number="4111111111111111",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
        )
        created_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)
        
        # 只更新有效期
        card_update = PaymentCardUpdate(card_expiry_month="10", card_expiry_year="26")
        updated_card = payment_card.update_card(db=db, db_obj=created_card, obj_in=card_update)
        
        assert updated_card.card_expiry_month == "10"
        assert updated_card.card_expiry_year == "26"
        assert updated_card.card_holder_name == created_card.card_holder_name
        assert updated_card.is_default == created_card.is_default


    def test_update_card_default_status(db: Session):
        """测试更新卡的默认状态"""
        # 创建两张卡，第一张是默认卡
        card1_in = PaymentCardCreate(
            card_holder_name="Test User 1",
            card_number="4111111111111111",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
            is_default=True,
        )
        card1 = payment_card.create_with_user(db=db, obj_in=card1_in, user_id=1)
        
        card2_in = PaymentCardCreate(
            card_holder_name="Test User 2",
            card_number="5555555555554444",
            card_expiry_month="10",
            card_expiry_year="24",
            cvv="456",
            is_default=False,
        )
        card2 = payment_card.create_with_user(db=db, obj_in=card2_in, user_id=1)
        
        # 更新第二张卡为默认卡
        card_update = PaymentCardUpdate(is_default=True)
        updated_card = payment_card.update_card(db=db, db_obj=card2, obj_in=card_update)
        assert updated_card.is_default is True
        
        # 验证第一张卡不再是默认卡
        db.refresh(card1)
        assert card1.is_default is False


    def test_delete_default_card(db: Session):
        """测试删除默认卡后的行为"""
        # 创建两张卡
        card1_in = PaymentCardCreate(
            card_holder_name="Default Card",
            card_number="4111111111111111",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
            is_default=True,
        )
        card1 = payment_card.create_with_user(db=db, obj_in=card1_in, user_id=1)
        
        card2_in = PaymentCardCreate(
            card_holder_name="Non-default Card",
            card_number="5555555555554444",
            card_expiry_month="10",
            card_expiry_year="24",
            cvv="456",
            is_default=False,
        )
        card2 = payment_card.create_with_user(db=db, obj_in=card2_in, user_id=1)
        
        # 删除默认卡
        payment_card.delete_by_id_and_user(db=db, id=card1.id, user_id=1)
        
        # 检查是否有默认卡
        default_card = payment_card.get_default_card(db=db, user_id=1)
        # 假设系统会自动将另一张卡设为默认卡
        assert default_card is not None
        assert default_card.id == card2.id
        assert default_card.is_default is True


    def test_multiple_users_with_same_card_number(db: Session):
        """测试多个用户使用相同卡号"""
        card_number = "4111111111111111"
        
        # 用户1创建卡
        card1_in = PaymentCardCreate(
            card_holder_name="User 1",
            card_number=card_number,
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
        )
        card1 = payment_card.create_with_user(db=db, obj_in=card1_in, user_id=1)
        
        # 用户2创建同样的卡
        card2_in = PaymentCardCreate(
            card_holder_name="User 2",
            card_number=card_number,
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
        )
        card2 = payment_card.create_with_user(db=db, obj_in=card2_in, user_id=2)
        
        # 验证两张卡是分开的
        assert card1.id != card2.id
        assert card1.user_id == 1
        assert card2.user_id == 2
        assert decrypt_card_data(card1.encrypted_card_number) == card_number
        assert decrypt_card_data(card2.encrypted_card_number) == card_number


    def test_pagination_for_user_cards(db: Session):
        """测试分页获取用户卡片"""
        # 清除用户的所有卡片
        cards = payment_card.get_by_user(db=db, user_id=1)
        for card in cards:
            payment_card.delete_by_id_and_user(db=db, id=card.id, user_id=1)
        
        # 创建5张卡片
        for i in range(5):
            card_in = PaymentCardCreate(
                card_holder_name=f"User Card {i}",
                card_number="4111111111111111",
                card_expiry_month="12",
                card_expiry_year="25",
                cvv="123",
                is_default=(i == 0),
            )
            payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)
        
        # 测试分页
        page1 = payment_card.get_by_user(db=db, user_id=1, skip=0, limit=2)
        assert len(page1) == 2
        
        page2 = payment_card.get_by_user(db=db, user_id=1, skip=2, limit=2)
        assert len(page2) == 2
        
        # 确保没有重复
        page1_ids = {card.id for card in page1}
        page2_ids = {card.id for card in page2}
        assert not page1_ids.intersection(page2_ids)


    def test_nonexistent_card_operations(db: Session):
        """测试对不存在卡片的操作"""
        # 尝试获取不存在的卡片
        nonexistent_card = payment_card.get_by_id_and_user(db=db, id=99999, user_id=1)
        assert nonexistent_card is None
        
        # 尝试更新不存在的卡片
        try:
            card_update = PaymentCardUpdate(card_holder_name="Updated Name")
            payment_card.update_card(db=db, db_obj=None, obj_in=card_update)
            assert False, "Should have raised an exception"
        except Exception:
            pass
        
        # 尝试删除不存在的卡片
        result = payment_card.delete_by_id_and_user(db=db, id=99999, user_id=1)
        assert result is None


    def test_multiple_updates(db: Session):
        """测试多次更新同一张卡"""
        card_in = PaymentCardCreate(
            card_holder_name="Original Name",
            card_number="4111111111111111",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
        )
        created_card = payment_card.create_with_user(db=db, obj_in=card_in, user_id=1)
        
        # 第一次更新
        update1 = PaymentCardUpdate(card_holder_name="First Update")
        card = payment_card.update_card(db=db, db_obj=created_card, obj_in=update1)
        assert card.card_holder_name == "First Update"
        
        # 第二次更新
        update2 = PaymentCardUpdate(card_expiry_month="11")
        card = payment_card.update_card(db=db, db_obj=card, obj_in=update2)
        assert card.card_holder_name == "First Update"
        assert card.card_expiry_month == "11"
        
        # 第三次更新
        update3 = PaymentCardUpdate(card_expiry_year="26", is_default=True)
        card = payment_card.update_card(db=db, db_obj=card, obj_in=update3)
        assert card.card_holder_name == "First Update"
        assert card.card_expiry_month == "11"
        assert card.card_expiry_year == "26"
        assert card.is_default is True


    def test_create_multiple_user_cards(db: Session):
        """测试为多个用户创建多张卡"""
        # 用户1的卡
        user1_card1 = PaymentCardCreate(
            card_holder_name="User 1 Card 1",
            card_number="4111111111111111",
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
            is_default=True,
        )
        payment_card.create_with_user(db=db, obj_in=user1_card1, user_id=1)
        
        user1_card2 = PaymentCardCreate(
            card_holder_name="User 1 Card 2",
            card_number="5555555555554444",
            card_expiry_month="11",
            card_expiry_year="24",
            cvv="456",
            is_default=False,
        )
        payment_card.create_with_user(db=db, obj_in=user1_card2, user_id=1)
        
        # 用户2的卡
        user2_card1 = PaymentCardCreate(
            card_holder_name="User 2 Card 1",
            card_number="4111111111111111",
            card_expiry_month="10",
            card_expiry_year="23",
            cvv="789",
            is_default=True,
        )
        payment_card.create_with_user(db=db, obj_in=user2_card1, user_id=2)
        
        # 验证用户1有两张卡
        user1_cards = payment_card.get_by_user(db=db, user_id=1)
        assert len(user1_cards) >= 2
        
        # 验证用户2有一张卡
        user2_cards = payment_card.get_by_user(db=db, user_id=2)
        assert len(user2_cards) >= 1
        
        # 验证用户的默认卡
        user1_default = payment_card.get_default_card(db=db, user_id=1)
        assert user1_default is not None
        assert user1_default.is_default is True
        
        user2_default = payment_card.get_default_card(db=db, user_id=2)
        assert user2_default is not None
        assert user2_default.is_default is True


    def test_card_number_validation(db: Session):
        """测试卡号验证"""
        # 创建有效的Visa卡
        valid_card = PaymentCardCreate(
            card_holder_name="Valid Card",
            card_number="4111111111111111",  # 有效的Visa卡号
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
        )
        valid_db_card = payment_card.create_with_user(db=db, obj_in=valid_card, user_id=1)
        assert valid_db_card is not None
        assert valid_db_card.card_type == "Visa"
        
        # 假设系统能识别不同的卡类型
        master_card = PaymentCardCreate(
            card_holder_name="MasterCard",
            card_number="5555555555554444",  # MasterCard卡号
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="123",
        )
        mc_db_card = payment_card.create_with_user(db=db, obj_in=master_card, user_id=1)
        assert mc_db_card is not None
        assert mc_db_card.card_type == "MasterCard"
        
        amex_card = PaymentCardCreate(
            card_holder_name="AmEx Card",
            card_number="378282246310005",  # American Express卡号
            card_expiry_month="12",
            card_expiry_year="25",
            cvv="1234",
        )
        amex_db_card = payment_card.create_with_user(db=db, obj_in=amex_card, user_id=1)
        assert amex_db_card is not None
        assert amex_db_card.card_type == "American Express"
