import sys
import os
from pathlib import Path

# 添加项目根目录到Python路径
root_dir = Path(__file__).parent.parent.parent
sys.path.insert(0, str(root_dir))

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.db.session import Base
from app.main import app
from app.api.deps import get_db
from app.core.security import create_access_token

# 使用SQLite内存数据库进行测试
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="function")
def db():
    Base.metadata.create_all(bind=engine)
    connection = engine.connect()
    transaction = connection.begin()
    db = TestingSessionLocal(bind=connection)
    try:
        yield db
    finally:
        db.close()
        transaction.rollback()
        connection.close()


@pytest.fixture(scope="module")
def client():
    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    Base.metadata.create_all(bind=engine)
    with TestClient(app) as client:
        yield client
    app.dependency_overrides.clear()
    Base.metadata.drop_all(bind=engine)


@pytest.fixture
def test_user_token():
    """创建测试用户并生成令牌"""
    # 不实际创建用户，只生成令牌用于测试
    token_data = {"sub": "test@example.com", "user_id": 1}
    return create_access_token(token_data)


@pytest.fixture
def test_admin_token():
    """创建管理员用户并生成令牌"""
    token_data = {"sub": "admin@example.com", "user_id": 2, "is_admin": True}
    return create_access_token(token_data)


@pytest.fixture
def auth_headers(test_user_token):
    return {"Authorization": f"Bearer {test_user_token}"}


@pytest.fixture
def admin_headers(test_admin_token):
    return {"Authorization": f"Bearer {test_admin_token}"}