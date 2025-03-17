from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

def test_read_main(client: TestClient):
    response = client.get("/")
    assert response.status_code == 200

def test_create_user(client: TestClient):
    response = client.post(
        "/api/v1/users/",
        json={
            "email": "test@example.com",
            "password": "testpassword",
            "full_name": "Test User"
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "test@example.com"
    assert data["full_name"] == "Test User"
    assert "id" in data

def test_login(client: TestClient):
    # First create a user
    client.post(
        "/api/v1/users/",
        json={
            "email": "login@example.com",
            "password": "testpassword",
            "full_name": "Login Test User"
        },
    )
    
    response = client.post(
        "/api/v1/login/access-token",
        data={
            "username": "login@example.com",
            "password": "testpassword"
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"