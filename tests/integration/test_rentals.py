import pytest
from fastapi import status
from app.schemas.rental import RentalPeriod, RentalCreate
from sqlalchemy.sql import text
import uuid


@pytest.fixture
def auth_client(client):
    """创建一个已认证的测试客户端"""
    # 创建用户
    user_data = {
        "email": "auth_test@example.com",
        "password": "authpassword123",
        "name": "Auth User",
    }
    client.post("/api/v1/users/", json=user_data)

    # 登录获取token
    login_data = {"username": "auth_test@example.com", "password": "authpassword123"}
    response = client.post("/api/v1/auth/login", data=login_data)
    token = response.json()["access_token"]

    # 设置认证头
    client.headers = {"Authorization": f"Bearer {token}"}
    return client


@pytest.fixture
def test_scooter(auth_client):
    """创建测试用滑板车"""
    scooter_data = {
        "model": f"Test Model {uuid.uuid4().hex[:8]}",
        "status": "available",
        "location": {"lat": 39.9087, "lng": 116.3914}
    }
    response = auth_client.post("/api/v1/scooters/", json=scooter_data)
    assert response.status_code == status.HTTP_201_CREATED
    return response.json()


def test_read_rentals(auth_client):
    """测试获取租赁列表"""
    response = auth_client.get("/api/v1/rentals/")
    assert response.status_code == status.HTTP_200_OK
    assert isinstance(response.json(), list)


def test_read_empty_rentals(auth_client):
    """测试获取空的租赁列表"""
    response = auth_client.get("/api/v1/rentals/")
    assert response.status_code == status.HTTP_200_OK
    assert len(response.json()) == 0


def test_read_rental_by_id_not_found(auth_client):
    """测试获取不存在的租赁订单"""
    response = auth_client.get("/api/v1/rentals/999999")
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_read_rental_by_invalid_id(auth_client):
    """测试使用无效ID获取租赁订单"""
    response = auth_client.get("/api/v1/rentals/invalid_id")
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_invalid_period(auth_client, test_scooter):
    """测试创建租赁订单时使用无效的租赁期限"""
    rental_data = {
        "scooter_id": test_scooter["id"],
        "rental_period": "invalid_period",
        "status": "active"
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_invalid_scooter_id(auth_client):
    """测试使用不存在的滑板车ID创建租赁订单"""
    rental_data = {
        "scooter_id": 999999,
        "rental_period": "1hr",
        "status": "active"
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_create_rental_invalid_status(auth_client, test_scooter):
    """测试创建租赁订单时使用无效的状态"""
    rental_data = {
        "scooter_id": test_scooter["id"],
        "rental_period": "1hr",
        "status": "invalid_status"
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_update_rental_not_found(auth_client):
    """测试更新不存在的租赁订单"""
    update_data = {"status": "completed"}
    response = auth_client.patch("/api/v1/rentals/999999", json=update_data)
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_create_rental_missing_scooter_id(auth_client):
    """测试创建租赁订单时缺少滑板车ID"""
    rental_data = {
        "rental_period": "1hr",
        "status": "active"
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_missing_period(auth_client, test_scooter):
    """测试创建租赁订单时缺少租赁期限"""
    rental_data = {
        "scooter_id": test_scooter["id"],
        "status": "active"
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_invalid_scooter_id_format(auth_client):
    """测试创建租赁订单时使用无效格式的滑板车ID"""
    rental_data = {
        "scooter_id": "invalid_id",
        "rental_period": "1hr",
        "status": "active"
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_empty_period(auth_client, test_scooter):
    """测试创建租赁订单时使用空租赁期限"""
    rental_data = {
        "scooter_id": test_scooter["id"],
        "rental_period": "",
        "status": "active"
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_empty_status(auth_client, test_scooter):
    """测试创建租赁订单时使用空状态"""
    rental_data = {
        "scooter_id": test_scooter["id"],
        "rental_period": "1hr",
        "status": ""
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_null_scooter_id(auth_client):
    """测试创建租赁订单时使用null滑板车ID"""
    rental_data = {
        "scooter_id": None,
        "rental_period": "1hr",
        "status": "active"
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_null_period(auth_client, test_scooter):
    """测试创建租赁订单时使用null租赁期限"""
    rental_data = {
        "scooter_id": test_scooter["id"],
        "rental_period": None,
        "status": "active"
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_null_status(auth_client, test_scooter):
    """测试创建租赁订单时使用null状态"""
    rental_data = {
        "scooter_id": test_scooter["id"],
        "rental_period": "1hr",
        "status": None
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_wrong_field_type(auth_client, test_scooter):
    """测试创建租赁订单时使用错误的字段类型"""
    rental_data = {
        "scooter_id": "not_a_number",
        "rental_period": 123,
        "status": 456
    }
    response = auth_client.post("/api/v1/rentals/", json=rental_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_empty_json(auth_client):
    """测试创建租赁订单时使用空JSON"""
    response = auth_client.post("/api/v1/rentals/", json={})
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_null_json(auth_client):
    """测试创建租赁订单时使用null JSON"""
    response = auth_client.post("/api/v1/rentals/", json=None)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_invalid_json(auth_client):
    """测试创建租赁订单时使用无效的JSON格式"""
    response = auth_client.post("/api/v1/rentals/", data="invalid json")
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_update_rental_invalid_json(auth_client):
    """测试使用无效的JSON格式更新租赁订单"""
    response = auth_client.patch("/api/v1/rentals/1", data="invalid json")
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
