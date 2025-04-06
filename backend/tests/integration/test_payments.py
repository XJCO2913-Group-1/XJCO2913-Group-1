import pytest
from fastapi import status
from sqlalchemy.orm import Session
from datetime import datetime

from app import crud, models
from app.schemas.user import UserCreate
from app.schemas.payment_card import PaymentCardCreate
from app.schemas.rental import RentalCreate
from app.schemas.scooter import ScooterCreate
from app.models.payment import PaymentStatus, PaymentMethod
from app.schemas.rental import RentalPeriod

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


@pytest.fixture
def test_rental(client, db: Session, test_user):
    # 创建一个测试用的租赁配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {
            "1hr": 1.0,
            "4hrs": 0.9,
            "1day": 0.8,
            "1week": 0.7
        },
        "description": "测试配置"
    }
    client.post("/api/v1/rental-configs/", json=config_data,
        headers=test_user["headers"]
    )
    
    # 创建一个可用的滑板车
    scooter_data = {
        "model": "Test Model",
        "status": "available",
        "location": {"lat": 39.9891, "lng": 116.3176}
    }
    scooter_response = client.post("/api/v1/scooters/", json=scooter_data, 
        headers=test_user["headers"]
    )
    assert scooter_response.status_code == status.HTTP_201_CREATED
    scooter_id = scooter_response.json()["id"]

    # 创建租赁订单
    rental_data = RentalCreate(
        scooter_id=scooter_id,
        rental_period=RentalPeriod.ONE_HOUR,
        status="active"
    )
    response = client.post("/api/v1/rentals/", json=rental_data.model_dump(),
        headers=test_user["headers"]
    )
    assert response.status_code == status.HTTP_201_CREATED
    
    # 结束租赁
    rental_id = response.json()["id"]
    end_response = client.post(
        f"/api/v1/rentals/{rental_id}/end",
        headers=test_user["headers"]
    )
    assert end_response.status_code == status.HTTP_200_OK
    
    return end_response.json()


def test_read_payments(client, test_user):
    """测试获取所有支付记录"""
    response = client.get(
        "/api/v1/payments/",
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)


def test_process_payment_with_new_card(client, test_user, test_rental):
    """测试使用新卡处理支付"""
    payment_data = {
        "rental_id": test_rental["id"],
        "amount": test_rental["cost"],
        "currency": "CNY",
        "payment_method": "card",
        "card_details": {
            "card_holder_name": "Test User",
            "card_number": "4111111111111111",
            "card_expiry_month": "12",
            "card_expiry_year": "25",
            "cvv": "123",
            "save_for_future": True,
            "set_as_default": True
        }
    }
    
    response = client.post(
        "/api/v1/payments/process", 
        json=payment_data,
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["status"] == "completed"
    assert data["rental_id"] == test_rental["id"]
    assert data["amount"] == test_rental["cost"]
    assert data["payment_method"] == "card"
    assert "transaction_id" in data
    assert "payment_id" in data
    assert "payment_date" in data


def test_process_payment_with_saved_card(client, test_user, test_rental, test_payment_card):
    """测试使用已保存的卡处理支付"""
    # 创建新的租赁
    rental_fixture = test_rental  # 使用已有的租赁夹具
    
    payment_data = {
        "rental_id": rental_fixture["id"],
        "amount": rental_fixture["cost"],
        "currency": "CNY",
        "payment_method": "saved_card",
        "payment_card_id": test_payment_card["id"]
    }
    
    response = client.post(
        "/api/v1/payments/process", 
        json=payment_data,
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["status"] == "completed"
    assert data["rental_id"] == rental_fixture["id"]
    assert data["amount"] == rental_fixture["cost"]
    assert data["payment_method"] == "saved_card"
    assert "transaction_id" in data


def test_process_payment_invalid_amount(client, test_user, test_rental):
    """测试处理金额不匹配的支付"""
    payment_data = {
        "rental_id": test_rental["id"],
        "amount": test_rental["cost"] + 10.0,  # 金额不匹配
        "currency": "CNY",
        "payment_method": "card",
        "card_details": {
            "card_holder_name": "Test User",
            "card_number": "4111111111111111",
            "card_expiry_month": "12",
            "card_expiry_year": "25",
            "cvv": "123"
        }
    }
    
    response = client.post(
        "/api/v1/payments/process", 
        json=payment_data,
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert "amount" in response.json()["detail"]


def test_process_payment_rental_not_found(client, test_user):
    """测试处理不存在租赁的支付"""
    payment_data = {
        "rental_id": 9999,  # 不存在的租赁ID
        "amount": 100.0,
        "currency": "CNY",
        "payment_method": "card",
        "card_details": {
            "card_holder_name": "Test User",
            "card_number": "4111111111111111",
            "card_expiry_month": "12",
            "card_expiry_year": "25",
            "cvv": "123"
        }
    }
    
    response = client.post(
        "/api/v1/payments/process", 
        json=payment_data,
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "Rental not found" in response.json()["detail"]


# def test_process_payment_invalid_card(client, test_user, test_rental):
#     """测试使用无效卡处理支付"""
#     payment_data = {
#         "rental_id": test_rental["id"],
#         "amount": test_rental["cost"],
#         "currency": "CNY",
#         "payment_method": "card",
#         "card_details": {
#             "card_holder_name": "Test User",
#             "card_number": "1234567890123456",  # 无效的卡号
#             "card_expiry_month": "12",
#             "card_expiry_year": "25",
#             "cvv": "123"
#         }
#     }
    
#     response = client.post(
#         "/api/v1/payments/process", 
#         json=payment_data,
#         headers=test_user["headers"]
#     )
    
#     assert response.status_code == status.HTTP_400_BAD_REQUEST
#     assert "卡号" in response.json()["detail"]


# def test_process_payment_expired_card(client, test_user, test_rental):
#     """测试使用过期卡处理支付"""
#     payment_data = {
#         "rental_id": test_rental["id"],
#         "amount": test_rental["cost"],
#         "currency": "CNY",
#         "payment_method": "card",
#         "card_details": {
#             "card_holder_name": "Test User",
#             "card_number": "4111111111111111",
#             "card_expiry_month": "01",
#             "card_expiry_year": "20",  # 过期年份
#             "cvv": "123"
#         }
#     }
    
#     response = client.post(
#         "/api/v1/payments/process", 
#         json=payment_data,
#         headers=test_user["headers"]
#     )
    
#     assert response.status_code == status.HTTP_400_BAD_REQUEST
#     assert "过期" in response.json()["detail"]


# def test_process_payment_missing_card_details(client, test_user, test_rental):
#     """测试缺少卡详情处理支付"""
#     payment_data = {
#         "rental_id": test_rental["id"],
#         "amount": test_rental["cost"],
#         "currency": "CNY",
#         "payment_method": "card"
#         # 缺少card_details
#     }
    
#     response = client.post(
#         "/api/v1/payments/process", 
#         json=payment_data,
#         headers=test_user["headers"]
#     )
    
#     assert response.status_code == status.HTTP_400_BAD_REQUEST
#     assert "Card details required" in response.json()["detail"]


def test_process_payment_invalid_saved_card(client, test_user, test_rental):
    """测试使用无效的已保存卡处理支付"""
    payment_data = {
        "rental_id": test_rental["id"],
        "amount": test_rental["cost"],
        "currency": "CNY",
        "payment_method": "saved_card",
        "payment_card_id": 9999  # 不存在的卡ID
    }
    
    response = client.post(
        "/api/v1/payments/process", 
        json=payment_data,
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "Payment card not found" in response.json()["detail"]


def test_read_payment(client, test_user, test_rental):
    """测试获取单个支付记录"""
    # 先创建一个支付
    payment_data = {
        "rental_id": test_rental["id"],
        "amount": test_rental["cost"],
        "currency": "CNY",
        "payment_method": "card",
        "card_details": {
            "card_holder_name": "Test User",
            "card_number": "4111111111111111",
            "card_expiry_month": "12",
            "card_expiry_year": "25",
            "cvv": "123"
        }
    }
    
    process_response = client.post(
        "/api/v1/payments/process", 
        json=payment_data,
        headers=test_user["headers"]
    )
    assert process_response.status_code == status.HTTP_200_OK
    payment_id = process_response.json()["payment_id"]
    
    # 获取该支付记录
    response = client.get(
        f"/api/v1/payments/{payment_id}",
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["id"] == payment_id
    assert data["rental_id"] == test_rental["id"]
    assert data["amount"] == test_rental["cost"]
    assert data["status"] == "completed"


def test_read_payment_not_found(client, test_user):
    """测试获取不存在的支付记录"""
    response = client.get(
        "/api/v1/payments/9999",
        headers=test_user["headers"]
    )
    
    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "Payment not found" in response.json()["detail"]