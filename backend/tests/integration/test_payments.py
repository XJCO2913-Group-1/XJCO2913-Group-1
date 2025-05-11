import pytest
from fastapi import status
from sqlalchemy.orm import Session

from app import crud
from app.schemas.user import UserCreate
from app.schemas.rental import RentalCreate
from app.schemas.rental import RentalPeriod


@pytest.fixture
def test_user(client, db: Session):
    """创建测试用户并返回"""
    import uuid

    # 生成唯一邮箱，避免测试冲突
    unique_id = str(uuid.uuid4())[:8]
    user_data = UserCreate(
        email=f"test_payment_{unique_id}@example.com",
        password="testpassword123",
        name="Test Payment User",
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
        "is_default": True,
    }

    response = client.post(
        "/api/v1/payment-cards/", json=card_data, headers=test_user["headers"]
    )
    assert response.status_code == status.HTTP_201_CREATED

    return response.json()


@pytest.fixture
def test_rental(client, db: Session, test_user):
    # 创建一个测试用的租赁配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0, "4hrs": 0.9, "1day": 0.8, "1week": 0.7},
        "description": "测试配置",
    }
    client.post(
        "/api/v1/rental-configs/", json=config_data, headers=test_user["headers"]
    )

    # 创建一个可用的滑板车
    scooter_data = {
        "model": "Test Model",
        "status": "available",
        "location": {"lat": 39.9891, "lng": 116.3176},
    }
    scooter_response = client.post(
        "/api/v1/scooters/", json=scooter_data, headers=test_user["headers"]
    )
    assert scooter_response.status_code == status.HTTP_201_CREATED
    scooter_id = scooter_response.json()["id"]

    # 创建租赁订单
    rental_data = RentalCreate(
        scooter_id=scooter_id, rental_period=RentalPeriod.ONE_HOUR, status="active"
    )
    response = client.post(
        "/api/v1/rentals/", json=rental_data.model_dump(), headers=test_user["headers"]
    )
    assert response.status_code == status.HTTP_201_CREATED

    # 结束租赁
    rental_id = response.json()["id"]
    end_response = client.post(
        f"/api/v1/rentals/{rental_id}/end", headers=test_user["headers"]
    )
    assert end_response.status_code == status.HTTP_200_OK

    return end_response.json()


def test_read_payments(client, test_user):
    """测试获取所有支付记录"""
    response = client.get("/api/v1/payments/", headers=test_user["headers"])

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)


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
            "cvv": "123",
        },
    }

    response = client.post(
        "/api/v1/payments/process", json=payment_data, headers=test_user["headers"]
    )

    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "Rental not found" in response.json()["detail"]


def test_read_payment_not_found(client, test_user):
    """测试获取不存在的支付记录"""
    response = client.get("/api/v1/payments/9999", headers=test_user["headers"])

    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "Payment not found" in response.json()["detail"]
