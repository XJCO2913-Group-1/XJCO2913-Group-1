import pytest
from datetime import datetime, timedelta
from fastapi import status
from app.schemas.rental import RentalPeriod, RentalCreate, RentalUpdate
from sqlalchemy.sql import text


@pytest.fixture
def auth_client(client):
    """创建一个已认证的测试客户端"""
    # 创建用户
    user_data = {
        "email": "auth@example.com",
        "password": "authpassword123",
        "name": "Auth User"
    }
    client.post("/api/v1/users/", json=user_data)
    
    # 登录获取token
    login_data = {
        "username": "auth@example.com",
        "password": "authpassword123"
    }
    response = client.post("/api/v1/auth/login", data=login_data)
    token = response.json()["access_token"]
    
    # 设置认证头
    client.headers = {"Authorization": f"Bearer {token}"}
    return client


def test_read_rentals(auth_client):
    """测试获取租赁列表"""
    response = auth_client.get("/api/v1/rentals/")
    assert response.status_code == status.HTTP_200_OK
    assert isinstance(response.json(), list)


def test_create_rental(auth_client, db):
    # 创建一个可用的滑板车
    scooter_data = {
        "model": "Test Model",
        "status": "available",
        "location": {"lat": 39.9891, "lng": 116.3176}
    }
    scooter_response = auth_client.post("/api/v1/scooters/", json=scooter_data)
    assert scooter_response.status_code == status.HTTP_201_CREATED
    scooter_id = scooter_response.json()["id"]

    # 创建租赁订单
    rental_data = RentalCreate(
        scooter_id=scooter_id,
        rental_period=RentalPeriod.ONE_HOUR,
        status="active"
    )
    response = auth_client.post("/api/v1/rentals/", json=rental_data.model_dump())

    current_user = auth_client.get("/api/v1/users/me")

    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["scooter_id"] == scooter_id
    assert data["user_id"] == current_user.json()["id"]
    assert data["status"] == "active"
    assert "cost" in data


def test_rental_cost_calculation(auth_client, db):
    """测试不同租赁时长的费用计算"""

    # 测试不同租赁时长 'expected': "'1hr', '4hrs', '1day' or '1week'"
    test_cases = [
        ("1hr", 20.0),
        ("4hrs", 72.0),
        ("1day", 384.0),
        ("1week", 2352.0),
        ("invalid", 0)
    ]
    
    for period, expected in test_cases:
        # 为每个测试用例创建新的滑板车
        scooter = auth_client.post("/api/v1/scooters/", json={
            "model": "Test Model",
            "status": "available",
            "location": {"lat": 39.9087, "lng": 116.3914}
        }).json()

        response = auth_client.post("/api/v1/rentals/", json={
            "scooter_id": scooter["id"],
            "rental_period": period,
            "status": "active"
        })

        if period == "invalid":
            assert response.status_code == 422
        else:
            if response.status_code != 201:
                assert False, f"error: {response.json()}"
            assert abs(response.json()["cost"] - expected) < 0.01, f"{period} duration cost error"


def test_rental_status_transition(auth_client, db):
    """测试租赁状态合法性转换"""
    # 创建滑板车和租赁订单
    scooter = auth_client.post("/api/v1/scooters/", json={
        "model": "Test Model",
        "status": "available",
        "location": {"lat": 39.9087, "lng": 116.3914}
    }).json()
    
    rental = auth_client.post("/api/v1/rentals/", json={
        "scooter_id": scooter["id"],
        "rental_period": "1hr",
        "status": "active"
    }).json()

    # 合法状态转换测试
    valid_update = {"status": "completed"}
    response = auth_client.patch(f"/api/v1/rentals/{rental['id']}", json=valid_update)
    assert response.status_code == 200

    # 非法状态转换测试
    invalid_update = {"status": "cancelled"}
    response = auth_client.patch(f"/api/v1/rentals/{rental['id']}", json=invalid_update)
    assert response.status_code == 400


# 在test_rental_status_transition测试后添加新测试

def test_user_authorization(auth_client, db):
    """测试非本人用户操作租赁订单"""
    # 创建第一个用户的租赁订单
    scooter = auth_client.post("/api/v1/scooters/", json={
        "model": "Auth Test",
        "status": "available",
        "location": {"lat": 39.91, "lng": 116.40}
    }).json()
    
    rental = auth_client.post("/api/v1/rentals/", json={
        "scooter_id": scooter["id"],
        "rental_period": "1hr",
        "status": "active"
    }).json()

    # 创建第二个用户
    another_user = {
        "email": "another@example.com",
        "password": "anotherpass123",
        "name": "Another User"
    }
    auth_client.post("/api/v1/users/", json=another_user)
    
    # 使用第二个用户尝试修改订单
    login_data = {"username": "another@example.com", "password": "anotherpass123"}
    another_client = auth_client
    another_client.headers = {"Authorization": f"Bearer {another_client.post('/api/v1/auth/login', data=login_data).json()['access_token']}"}
    
    response = another_client.patch(f"/api/v1/rentals/{rental['id']}", json={"status": "completed"})
    assert response.status_code == 403


def test_rental_timeout_completion(auth_client, db):
    """测试租赁超时自动完成"""
    # 创建测试订单（设置1小时租赁时长）
    scooter = auth_client.post("/api/v1/scooters/", json={
        "model": "Timeout Test",
        "status": "available",
        "location": {"lat": 39.92, "lng": 116.41}
    }).json()
    
    rental = auth_client.post("/api/v1/rentals/", json={
        "scooter_id": scooter["id"],
        "rental_period": "1hr",
        "status": "active"
    }).json()

    # 模拟超时（手动修改开始时间为2小时前）
    db.execute(text("UPDATE rentals SET start_time = datetime('now','-2 hours') WHERE id = :id"), {"id": rental["id"]})
    # 触发定时任务检查
    from app import crud
    crud.rental.check_expired_rentals(db=db)
    db.commit()

    # 验证状态更新
    updated_rental = auth_client.get(f"/api/v1/rentals/{rental['id']}").json()
    assert updated_rental["status"] == "completed"
    assert "end_time" in updated_rental

