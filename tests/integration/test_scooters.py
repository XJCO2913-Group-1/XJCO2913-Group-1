from fastapi import status


def test_read_scooters(client):
    """测试获取滑板车列表"""
    response = client.get("/api/v1/scooters/")
    assert response.status_code == status.HTTP_200_OK
    assert isinstance(response.json(), list)


def test_create_scooter(client):
    """测试创建新滑板车"""
    scooter_data = {
        "model": "Xiaomi M365",
        "status": "available",
        "location": {"lat": 39.9891, "lng": 116.3176},  # 海淀区经纬度
        "battery_level": 100,
    }
    response = client.post("/api/v1/scooters/", json=scooter_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["model"] == scooter_data["model"]
    assert data["status"] == scooter_data["status"]
    assert data["location"] == scooter_data["location"]
    assert data["battery_level"] == scooter_data["battery_level"]
    assert "id" in data


def test_read_scooter(client):
    """测试获取单个滑板车"""
    # 先创建一个滑板车
    scooter_data = {
        "model": "Ninebot Max",
        "status": "available",
        "location": {"lat": 39.9219, "lng": 116.4402},  # 朝阳区经纬度
        "battery_level": 95,
    }
    response = client.post("/api/v1/scooters/", json=scooter_data)
    assert response.status_code == status.HTTP_201_CREATED
    scooter_id = response.json()["id"]

    # 获取该滑板车
    response = client.get(f"/api/v1/scooters/{scooter_id}")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["model"] == scooter_data["model"]
    assert data["status"] == scooter_data["status"]
    assert data["location"] == scooter_data["location"]
    assert data["battery_level"] == scooter_data["battery_level"]


def test_read_scooter_not_found(client):
    """测试获取不存在的滑板车"""
    response = client.get("/api/v1/scooters/999")
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_update_scooter(client):
    """测试更新滑板车信息"""
    # 先创建一个滑板车
    scooter_data = {
        "model": "Segway ES2",
        "status": "available",
        "location": {"lat": 39.9087, "lng": 116.3914},  # 西城区经纬度
        "battery_level": 90,
    }
    response = client.post("/api/v1/scooters/", json=scooter_data)
    assert response.status_code == status.HTTP_201_CREATED
    scooter_id = response.json()["id"]

    # 更新滑板车信息
    update_data = {"status": "maintenance", "battery_level": 20}
    response = client.put(f"/api/v1/scooters/{scooter_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["status"] == update_data["status"]
    assert data["battery_level"] == update_data["battery_level"]
    assert data["model"] == scooter_data["model"]
    assert data["location"] == scooter_data["location"]


def test_delete_scooter(client):
    """测试删除滑板车"""
    # 先创建一个滑板车
    scooter_data = {
        "model": "Xiaomi Pro 2",
        "status": "available",
        "location": {"lat": 39.9175, "lng": 116.4076},  # 东城区经纬度
        "battery_level": 85,
    }
    response = client.post("/api/v1/scooters/", json=scooter_data)
    assert response.status_code == status.HTTP_201_CREATED
    scooter_id = response.json()["id"]

    # 删除该滑板车
    response = client.delete(f"/api/v1/scooters/{scooter_id}")
    assert response.status_code == status.HTTP_200_OK

    # 确认滑板车已被删除
    response = client.get(f"/api/v1/scooters/{scooter_id}")
    assert response.status_code == status.HTTP_404_NOT_FOUND
