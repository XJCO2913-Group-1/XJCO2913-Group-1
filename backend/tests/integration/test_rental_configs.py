import pytest
from fastapi import status
from app.schemas.rental_config import RentalConfigCreate

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

def test_read_rental_configs(auth_client):
    """测试获取租赁配置列表"""
    response = auth_client.get("/api/v1/rental-configs/")
    assert response.status_code == status.HTTP_200_OK
    assert isinstance(response.json(), list)

def test_get_active_config(auth_client):
    """测试获取当前生效的租赁配置"""
    # 创建一个配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {
            "1hr": 1.0,
            "4hrs": 0.9,
            "1day": 0.8,
            "1week": 0.7
        },
        "is_active": 1 
    }
    auth_client.post("/api/v1/rental-configs/", json=config_data)
    
    response = auth_client.get("/api/v1/rental-configs/active")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == 20.0
    assert data["is_active"] == True

def test_create_rental_config(auth_client):
    """测试创建新的租赁配置"""
    config_data = {
        "base_hourly_rate": 25.0,
        "period_discounts": {"1hr": 1.0},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    print(response.json())
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["base_hourly_rate"] == 25.0
    assert data["is_active"] == True

def test_update_rental_config(auth_client):
    """测试更新租赁配置"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]
    
    # 更新配置
    update_data = {
        "base_hourly_rate": 30.0,
        "period_discounts": {"1hr": 0.9}
    }
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == 30.0
    assert data["period_discounts"]["1hr"] == 0.9

def test_invalid_config_creation(auth_client):
    """测试创建无效配置的错误处理"""
    # 测试负数基础费率
    invalid_data = {
        "base_hourly_rate": -20.0,
        "period_discounts": {"1hr": 1.0},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=invalid_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
    
    # 测试无效的折扣率
    invalid_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 2.0},  # 折扣率不能大于1
        "is_active": 1
    }
    response = auth_client.post("/api/v1/rental-configs/", json=invalid_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY