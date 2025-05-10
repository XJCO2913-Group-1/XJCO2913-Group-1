import pytest
from fastapi import status


@pytest.fixture
def auth_client(client):
    """创建一个已认证的测试客户端"""
    # 创建用户
    user_data = {
        "email": "auth@example.com",
        "password": "authpassword123",
        "name": "Auth User",
    }
    client.post("/api/v1/users/", json=user_data)

    # 登录获取token
    login_data = {"username": "auth@example.com", "password": "authpassword123"}
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
    update_data = {"base_hourly_rate": 30.0, "period_discounts": {"1hr": 0.9}}
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
    }
    response = auth_client.post("/api/v1/rental-configs/", json=invalid_data)
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


def test_create_rental_config_with_different_rates(auth_client):
    """测试使用不同的基础费率创建租赁配置"""
    config_data = {
        "base_hourly_rate": 15.0,
        "period_discounts": {"1hr": 1.0},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["base_hourly_rate"] == 15.0


def test_create_rental_config_with_multiple_discounts(auth_client):
    """测试创建包含多个折扣的租赁配置"""
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {
            "1hr": 1.0,
            "4hrs": 0.9,
            "1day": 0.8,
            "1week": 0.7
        },
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert len(data["period_discounts"]) == 4


def test_update_rental_config_base_rate(auth_client):
    """测试更新租赁配置的基础费率"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 更新基础费率
    update_data = {"base_hourly_rate": 25.0}
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == 25.0


def test_update_rental_config_discounts(auth_client):
    """测试更新租赁配置的折扣"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 更新折扣
    update_data = {
        "period_discounts": {
            "1hr": 1.0,
            "4hrs": 0.9
        }
    }
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert len(data["period_discounts"]) == 2


def test_create_rental_config_with_minimal_data(auth_client):
    """测试使用最小数据创建租赁配置"""
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED


def test_update_rental_config_partial(auth_client):
    """测试部分更新租赁配置"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 部分更新
    update_data = {"base_hourly_rate": 22.0}
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == 22.0
    assert data["period_discounts"]["1hr"] == 1.0


def test_create_rental_config_with_full_discount(auth_client):
    """测试创建包含全额折扣的租赁配置"""
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 0.0},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["period_discounts"]["1hr"] == 0.0


def test_update_rental_config_with_same_data(auth_client):
    """测试使用相同数据更新租赁配置"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 使用相同数据更新
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=config_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == config_data["base_hourly_rate"]
    assert data["period_discounts"] == config_data["period_discounts"]


def test_create_rental_config_with_decimal_rates(auth_client):
    """测试创建包含小数费率的租赁配置"""
    config_data = {
        "base_hourly_rate": 19.99,
        "period_discounts": {"1hr": 1.0},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["base_hourly_rate"] == 19.99


def test_create_rental_config_with_decimal_discounts(auth_client):
    """测试创建包含小数折扣的租赁配置"""
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 0.95},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["period_discounts"]["1hr"] == 0.95


def test_update_rental_config_with_decimal_values(auth_client):
    """测试使用小数值更新租赁配置"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 使用小数值更新
    update_data = {
        "base_hourly_rate": 19.99,
        "period_discounts": {"1hr": 0.95}
    }
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == 19.99
    assert data["period_discounts"]["1hr"] == 0.95


def test_create_rental_config_with_high_rate(auth_client):
    """测试创建高费率的租赁配置"""
    config_data = {
        "base_hourly_rate": 1000.0,
        "period_discounts": {"1hr": 1.0},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["base_hourly_rate"] == 1000.0


def test_create_rental_config_with_small_discount(auth_client):
    """测试创建包含小折扣的租赁配置"""
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 0.01},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["period_discounts"]["1hr"] == 0.01


def test_create_rental_config_with_different_rate_1(auth_client):
    """测试使用不同的基础费率创建租赁配置1"""
    config_data = {
        "base_hourly_rate": 18.0,
        "period_discounts": {"1hr": 1.0},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["base_hourly_rate"] == 18.0


def test_create_rental_config_with_different_rate_2(auth_client):
    """测试使用不同的基础费率创建租赁配置2"""
    config_data = {
        "base_hourly_rate": 22.0,
        "period_discounts": {"1hr": 1.0},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["base_hourly_rate"] == 22.0


def test_create_rental_config_with_different_rate_3(auth_client):
    """测试使用不同的基础费率创建租赁配置3"""
    config_data = {
        "base_hourly_rate": 28.0,
        "period_discounts": {"1hr": 1.0},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["base_hourly_rate"] == 28.0


def test_create_rental_config_with_different_discount_1(auth_client):
    """测试使用不同的折扣创建租赁配置1"""
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 0.98},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["period_discounts"]["1hr"] == 0.98


def test_create_rental_config_with_different_discount_2(auth_client):
    """测试使用不同的折扣创建租赁配置2"""
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 0.97},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["period_discounts"]["1hr"] == 0.97


def test_create_rental_config_with_different_discount_3(auth_client):
    """测试使用不同的折扣创建租赁配置3"""
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 0.96},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["period_discounts"]["1hr"] == 0.96


def test_update_rental_config_with_different_rate_1(auth_client):
    """测试使用不同的费率更新租赁配置1"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 更新费率
    update_data = {"base_hourly_rate": 23.0}
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == 23.0


def test_update_rental_config_with_different_rate_2(auth_client):
    """测试使用不同的费率更新租赁配置2"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 更新费率
    update_data = {"base_hourly_rate": 24.0}
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == 24.0


def test_update_rental_config_with_different_rate_3(auth_client):
    """测试使用不同的费率更新租赁配置3"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 更新费率
    update_data = {"base_hourly_rate": 26.0}
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == 26.0


def test_update_rental_config_with_different_discount_1(auth_client):
    """测试使用不同的折扣更新租赁配置1"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 更新折扣
    update_data = {"period_discounts": {"1hr": 0.94}}
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["period_discounts"]["1hr"] == 0.94


def test_update_rental_config_with_different_discount_2(auth_client):
    """测试使用不同的折扣更新租赁配置2"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 更新折扣
    update_data = {"period_discounts": {"1hr": 0.93}}
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["period_discounts"]["1hr"] == 0.93


def test_update_rental_config_with_different_discount_3(auth_client):
    """测试使用不同的折扣更新租赁配置3"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 更新折扣
    update_data = {"period_discounts": {"1hr": 0.92}}
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["period_discounts"]["1hr"] == 0.92


def test_create_rental_config_with_different_rates_1(auth_client):
    """测试使用不同的费率组合创建租赁配置1"""
    config_data = {
        "base_hourly_rate": 17.0,
        "period_discounts": {"1hr": 0.99},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["base_hourly_rate"] == 17.0
    assert data["period_discounts"]["1hr"] == 0.99


def test_create_rental_config_with_different_rates_2(auth_client):
    """测试使用不同的费率组合创建租赁配置2"""
    config_data = {
        "base_hourly_rate": 21.0,
        "period_discounts": {"1hr": 0.98},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["base_hourly_rate"] == 21.0
    assert data["period_discounts"]["1hr"] == 0.98


def test_create_rental_config_with_different_rates_3(auth_client):
    """测试使用不同的费率组合创建租赁配置3"""
    config_data = {
        "base_hourly_rate": 27.0,
        "period_discounts": {"1hr": 0.97},
    }
    response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["base_hourly_rate"] == 27.0
    assert data["period_discounts"]["1hr"] == 0.97


def test_update_rental_config_with_different_rates_1(auth_client):
    """测试使用不同的费率组合更新租赁配置1"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 更新费率组合
    update_data = {
        "base_hourly_rate": 25.0,
        "period_discounts": {"1hr": 0.96}
    }
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == 25.0
    assert data["period_discounts"]["1hr"] == 0.96


def test_update_rental_config_with_different_rates_2(auth_client):
    """测试使用不同的费率组合更新租赁配置2"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 更新费率组合
    update_data = {
        "base_hourly_rate": 29.0,
        "period_discounts": {"1hr": 0.95}
    }
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == 29.0
    assert data["period_discounts"]["1hr"] == 0.95


def test_update_rental_config_with_different_rates_3(auth_client):
    """测试使用不同的费率组合更新租赁配置3"""
    # 创建配置
    config_data = {
        "base_hourly_rate": 20.0,
        "period_discounts": {"1hr": 1.0},
    }
    create_response = auth_client.post("/api/v1/rental-configs/", json=config_data)
    config_id = create_response.json()["id"]

    # 更新费率组合
    update_data = {
        "base_hourly_rate": 31.0,
        "period_discounts": {"1hr": 0.94}
    }
    response = auth_client.put(f"/api/v1/rental-configs/{config_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["base_hourly_rate"] == 31.0
    assert data["period_discounts"]["1hr"] == 0.94
