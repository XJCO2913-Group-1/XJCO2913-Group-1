import pytest
from fastapi import status
from sqlalchemy.orm import Session

from app import crud, models
from app.schemas.user import UserCreate
from app.schemas.payment_card import PaymentCardCreate


@pytest.fixture
def test_user(client, db: Session):
    """创建测试用户并返回"""
    import uuid
    # 生成唯一邮箱，避免测试冲突
    unique_id = str(uuid.uuid4())[:8]
    user_data = UserCreate(
        email=f"test_payment_cards_{unique_id}@example.com",
        password="testpassword123",
        name="Test Payment Cards User"
    )
    response = client.post("/api/v1/users/", json=user_data.model_dump())
    assert response.status_code == status.HTTP_201_CREATED
    
    # 获取创建的用户
    user = crud.user.get_by_email(db=db, email=user_data.email)
    
    # 创建访问令牌
    token_data = {"username": user_data.email, "password": user_data.password}
    token_response = client.post("/api/v1/auth/login", data=token_data)
    assert token_response.status_code == status.HTTP_200_OK
    
    token = token_response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    
    return {"user": user, "headers": headers}


@pytest.fixture
def test_payment_card(client, test_user):
    """创建测试支付卡并返回"""
    card_data = {
        "card_holder_name": "Test User",
        "card_number": "4111111111111111",
        "card_expiry_month": "12",
        "card_expiry_year": "25",
        "cvv": "123",
        "is_default": True
    }
    
    response = client.post(
        "/api/v1/payment-cards/", 
        json=card_data,
        headers=test_user["headers"]
    )
    assert response.status_code == status.HTTP_201_CREATED
    
    return response.json()


def test_create_payment_card(client, test_user):
    """测试创建支付卡"""
    card_data = {
        "card_holder_name": "Test User",
        "card_number": "4111111111111111",
        "card_expiry_month": "12",
        "card_expiry_year": "25",
        "cvv": "123",
        "is_default": True
    }
    
    response = client.post(
        "/api/v1/payment-cards/", 
        json=card_data,
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["card_holder_name"] == card_data["card_holder_name"]
    assert data["card_number_last4"] == card_data["card_number"][-4:]
    assert data["card_expiry_month"] == card_data["card_expiry_month"]
    assert data["card_expiry_year"] == card_data["card_expiry_year"]
    assert data["is_default"] == True
    assert data["card_type"] == "Visa"
    assert "id" in data
    
    # 敏感信息不应该返回
    assert "card_number" not in data
    assert "cvv" not in data


def test_read_payment_cards(client, test_user, test_payment_card):
    """测试获取所有支付卡"""
    response = client.get(
        "/api/v1/payment-cards/",
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    
    # 验证返回的卡包含我们创建的卡
    card_ids = [card["id"] for card in data]
    assert test_payment_card["id"] in card_ids


def test_read_payment_card(client, test_user, test_payment_card):
    """测试获取单个支付卡"""
    response = client.get(
        f"/api/v1/payment-cards/{test_payment_card['id']}",
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["id"] == test_payment_card["id"]
    assert data["card_holder_name"] == test_payment_card["card_holder_name"]
    assert data["card_number_last4"] == test_payment_card["card_number_last4"]


def test_read_payment_card_not_found(client, test_user):
    """测试获取不存在的支付卡"""
    response = client.get(
        "/api/v1/payment-cards/9999",
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_read_default_payment_card(client, test_user, test_payment_card):
    """测试获取默认支付卡"""
    response = client.get(
        "/api/v1/payment-cards/default",
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["is_default"] == True
    assert data["id"] == test_payment_card["id"]


def test_update_payment_card(client, test_user, test_payment_card):
    """测试更新支付卡"""
    update_data = {
        "card_holder_name": "Updated User",
        "card_expiry_month": "11"
    }
    
    response = client.put(
        f"/api/v1/payment-cards/{test_payment_card['id']}",
        json=update_data,
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["card_holder_name"] == update_data["card_holder_name"]
    assert data["card_expiry_month"] == update_data["card_expiry_month"]
    assert data["card_expiry_year"] == test_payment_card["card_expiry_year"]
    assert data["id"] == test_payment_card["id"]


def test_update_payment_card_not_found(client, test_user):
    """测试更新不存在的支付卡"""
    update_data = {"card_holder_name": "Updated User"}
    
    response = client.put(
        "/api/v1/payment-cards/9999",
        json=update_data,
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_delete_payment_card(client, test_user, test_payment_card):
    """测试删除支付卡"""
    # 先创建一个新卡，以免删除测试夹具中的卡影响其他测试
    card_data = {
        "card_holder_name": "Delete Test",
        "card_number": "5555555555554444",
        "card_expiry_month": "10",
        "card_expiry_year": "24",
        "cvv": "456",
        "is_default": False
    }
    
    create_response = client.post(
        "/api/v1/payment-cards/", 
        json=card_data,
        headers=test_user["headers"]
    )
    assert create_response.status_code == status.HTTP_201_CREATED
    card_to_delete = create_response.json()
    
    # 删除卡
    response = client.delete(
        f"/api/v1/payment-cards/{card_to_delete['id']}",
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["id"] == card_to_delete["id"]
    
    # 验证卡已被删除
    get_response = client.get(
        f"/api/v1/payment-cards/{card_to_delete['id']}",
        headers=test_user["headers"]
    )
    assert get_response.status_code == status.HTTP_404_NOT_FOUND


def test_delete_payment_card_not_found(client, test_user):
    """测试删除不存在的支付卡"""
    response = client.delete(
        "/api/v1/payment-cards/9999",
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_multiple_cards_default_handling(client, test_user, test_payment_card):
    """测试多张卡的默认卡处理"""
    # 创建第二张卡（设为默认）
    card_data = {
        "card_holder_name": "Second User",
        "card_number": "5555555555554444",
        "card_expiry_month": "10",
        "card_expiry_year": "24",
        "cvv": "456",
        "is_default": True
    }
    
    response = client.post(
        "/api/v1/payment-cards/", 
        json=card_data,
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_201_CREATED
    second_card = response.json()
    assert second_card["is_default"] == True
    
    # 验证第一张卡不再是默认卡
    first_card_response = client.get(
        f"/api/v1/payment-cards/{test_payment_card['id']}",
        headers=test_user["headers"]
    )
    assert first_card_response.status_code == status.HTTP_200_OK
    first_card = first_card_response.json()
    assert first_card["is_default"] == False
    
    # 验证默认卡API返回第二张卡
    default_response = client.get(
        "/api/v1/payment-cards/default",
        headers=test_user["headers"]
    )
    assert default_response.status_code == status.HTTP_200_OK
    default_card = default_response.json()
    assert default_card["id"] == second_card["id"]