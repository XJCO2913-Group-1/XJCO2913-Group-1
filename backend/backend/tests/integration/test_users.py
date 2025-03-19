import pytest
from fastapi import status
from app.schemas.user import UserCreate


def test_read_users(client):
    """测试获取用户列表"""
    response = client.get("/api/v1/users/")
    assert response.status_code == status.HTTP_200_OK
    assert isinstance(response.json(), list)


def test_create_user(client):
    """测试创建新用户"""
    user_data = {
        "email": "test@example.com",
        "password": "testpassword123",
        "name": "Test User"
    }
    response = client.post("/api/v1/users/", json=user_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["email"] == user_data["email"]
    assert data["name"] == user_data["name"]
    assert "id" in data


def test_create_user_duplicate_email(client):
    """测试创建重复邮箱的用户"""
    user_data = {
        "email": "duplicate@example.com",
        "password": "testpassword123",
        "name": "Duplicate User"
    }
    # 第一次创建用户
    response = client.post("/api/v1/users/", json=user_data)
    assert response.status_code == status.HTTP_201_CREATED

    # 尝试创建相同邮箱的用户
    response = client.post("/api/v1/users/", json=user_data)
    assert response.status_code == status.HTTP_400_BAD_REQUEST


def test_read_user(client):
    """测试获取单个用户"""
    # 先创建一个用户
    user_data = {
        "email": "read@example.com",
        "password": "testpassword123",
        "name": "Read User"
    }
    response = client.post("/api/v1/users/", json=user_data)
    assert response.status_code == status.HTTP_201_CREATED
    user_id = response.json()["id"]

    # 获取该用户
    response = client.get(f"/api/v1/users/{user_id}")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["email"] == user_data["email"]
    assert data["name"] == user_data["name"]


def test_read_user_not_found(client):
    """测试获取不存在的用户"""
    response = client.get("/api/v1/users/999")
    assert response.status_code == status.HTTP_404_NOT_FOUND


def test_update_user(client):
    """测试更新用户信息"""
    # 先创建一个用户
    user_data = {
        "email": "update@example.com",
        "password": "testpassword123",
        "name": "Update User"
    }
    response = client.post("/api/v1/users/", json=user_data)
    assert response.status_code == status.HTTP_201_CREATED
    user_id = response.json()["id"]

    # 更新用户信息
    update_data = {
        "name": "Updated Name"
    }
    response = client.patch(f"/api/v1/users/{user_id}", json=update_data)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["name"] == update_data["name"]


def test_delete_user(client):
    """测试删除用户"""
    # 先创建一个用户
    user_data = {
        "email": "delete@example.com",
        "password": "testpassword123",
        "name": "Delete User"
    }
    response = client.post("/api/v1/users/", json=user_data)
    assert response.status_code == status.HTTP_201_CREATED
    user_id = response.json()["id"]

    # 删除该用户
    response = client.delete(f"/api/v1/users/{user_id}")
    assert response.status_code == status.HTTP_204_NO_CONTENT

    # 确认用户已被删除
    response = client.get(f"/api/v1/users/{user_id}")
    assert response.status_code == status.HTTP_404_NOT_FOUND