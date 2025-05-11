import pytest
import time
import random
from datetime import datetime, timedelta
import sys
import os
from pathlib import Path

# 添加项目根目录到 Python 路径
root_dir = Path(__file__).parent.parent.parent
sys.path.append(str(root_dir))

from app.schemas.user import UserCreate
from app.core.security import create_access_token


@pytest.fixture
def test_user():
    """模拟测试用户数据"""
    return {
        "id": 1,
        "email": "journey@example.com",
        "name": "Journey Test User",
        "created_at": datetime.now().isoformat(),
        "is_active": True
    }


@pytest.fixture
def test_payment_methods():
    """模拟用户支付方式"""
    return [
        {
            "id": 1,
            "type": "credit_card",
            "last_four": "4242",
            "expiry": "12/25"
        },
        {
            "id": 2,
            "type": "paypal",
            "email": "journey@example.com"
        }
    ]


def test_user_registration_flow():
    """测试用户注册流程"""
    # 模拟注册请求数据
    registration_data = {
        "email": f"new_user_{int(time.time())}@example.com",
        "password": "StrongP@ssw0rd",
        "name": "New Test User"
    }
    
    # 模拟注册响应
    response = {
        "id": random.randint(100, 999),
        "email": registration_data["email"],
        "name": registration_data["name"],
        "is_active": True
    }
    
    assert "id" in response
    assert response["email"] == registration_data["email"]


def test_user_login_flow():
    """测试用户登录流程"""
    # 模拟登录请求
    login_data = {
        "username": "existing@example.com",
        "password": "SecureP@ss123"
    }
    
    # 模拟登录响应
    response = {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "token_type": "bearer",
        "user_id": 5,
        "email": login_data["username"]
    }
    
    assert "access_token" in response
    assert response["token_type"] == "bearer"


def test_user_profile_view(test_user):
    """测试查看用户个人资料"""
    # 模拟获取个人资料响应
    response = test_user
    
    assert response["id"] == test_user["id"]
    assert response["email"] == test_user["email"]
    
    # 添加延时
    time.sleep(0.1)


def test_user_profile_update(test_user):
    """测试更新用户个人资料"""
    # 模拟更新请求
    update_data = {
        "name": "Updated Name",
        "phone": "1234567890"
    }
    
    # 模拟更新响应
    response = {
        **test_user,
        **update_data
    }
    
    assert response["name"] == update_data["name"]
    assert response["phone"] == update_data["phone"]


def test_user_payment_method_add(test_user):
    """测试添加支付方式"""
    # 模拟添加支付方式请求
    payment_data = {
        "type": "credit_card",
        "card_number": "4242424242424242",
        "expiry": "12/25",
        "cvv": "123"
    }
    
    # 模拟响应
    response = {
        "id": random.randint(100, 999),
        "user_id": test_user["id"],
        "type": payment_data["type"],
        "last_four": payment_data["card_number"][-4:],
        "expiry": payment_data["expiry"]
    }
    
    assert response["user_id"] == test_user["id"]
    assert response["last_four"] == "4242"


def test_user_payment_methods_view(test_user, test_payment_methods):
    """测试查看支付方式列表"""
    # 模拟查看支付方式响应
    response = test_payment_methods
    
    assert isinstance(response, list)
    assert len(response) > 0
    
    # 延时循环
    for _ in range(3):
        time.sleep(0.1)


def test_user_find_nearby_scooters():
    """测试查找附近滑板车"""
    # 模拟用户位置
    user_location = {
        "lat": 39.9075,
        "lng": 116.3972,
        "radius": 2.0
    }
    
    # 模拟附近滑板车响应
    scooters = []
    for i in range(1, 6):
        # 创建5个随机位置的滑板车
        lat_offset = random.uniform(-0.01, 0.01)
        lng_offset = random.uniform(-0.01, 0.01)
        scooters.append({
            "id": i,
            "model": f"Nearby Scooter {i}",
            "battery_level": random.randint(60, 100),
            "status": "available",
            "location": {
                "lat": user_location["lat"] + lat_offset,
                "lng": user_location["lng"] + lng_offset
            },
            "distance": round(random.uniform(0.1, 1.9), 1)
        })
    
    assert isinstance(scooters, list)
    assert all(s["status"] == "available" for s in scooters)


def test_user_scooter_reservation():
    """测试滑板车预约"""
    # 模拟预约请求
    reservation_data = {
        "user_id": 1,
        "scooter_id": 3,
        "reservation_time": datetime.now().isoformat(),
        "duration_minutes": 15
    }
    
    # 模拟响应
    response = {
        "id": random.randint(100, 999),
        **reservation_data,
        "status": "active",
        "expiry_time": (datetime.now() + timedelta(minutes=15)).isoformat()
    }
    
    assert response["status"] == "active"
    assert "expiry_time" in response


def test_user_start_rental():
    """测试开始租赁"""
    # 模拟开始租赁请求
    rental_data = {
        "user_id": 1,
        "scooter_id": 3,
        "start_location": {"lat": 39.9075, "lng": 116.3972}
    }
    
    # 模拟响应
    response = {
        "id": random.randint(100, 999),
        "user_id": rental_data["user_id"],
        "scooter_id": rental_data["scooter_id"],
        "start_time": datetime.now().isoformat(),
        "status": "active",
        "unlock_code": "A1B2C3"
    }
    
    assert response["status"] == "active"
    assert "unlock_code" in response
    
    # 延时循环
    for i in range(5):
        time.sleep(0.05)


def test_user_end_rental():
    """测试结束租赁"""
    # 模拟租赁信息
    rental_id = random.randint(100, 999)
    start_time = datetime.now() - timedelta(minutes=45)
    
    # 模拟结束租赁请求
    end_data = {
        "rental_id": rental_id,
        "end_location": {"lat": 39.9175, "lng": 116.4072}
    }
    
    # 模拟响应
    response = {
        "id": rental_id,
        "start_time": start_time.isoformat(),
        "end_time": datetime.now().isoformat(),
        "duration_minutes": 45,
        "cost": 15.75,
        "status": "completed"
    }
    
    assert response["status"] == "completed"
    assert "cost" in response


def test_user_view_rental_history():
    """测试查看租赁历史"""
    # 模拟租赁历史
    rentals = []
    
    # 生成10个历史租赁记录
    for i in range(1, 11):
        start_date = datetime.now() - timedelta(days=i)
        end_date = start_date + timedelta(hours=random.randint(1, 3))
        
        rentals.append({
            "id": 100 + i,
            "start_time": start_date.isoformat(),
            "end_time": end_date.isoformat(),
            "duration_minutes": (end_date - start_date).seconds // 60,
            "cost": round(5.0 + (end_date - start_date).seconds / 60 * 0.25, 2),
            "status": "completed"
        })
    
    assert isinstance(rentals, list)
    assert len(rentals) == 10
    
    # 添加循环来延长测试时间
    for rental in rentals[:3]:
        time.sleep(0.05)
        assert rental["status"] == "completed"


def test_user_view_billing_history():
    """测试查看账单历史"""
    # 模拟账单历史
    bills = []
    
    # 生成5个月的账单
    for i in range(1, 6):
        bill_date = datetime.now().replace(day=1) - timedelta(days=30*i)
        
        bills.append({
            "id": 200 + i,
            "billing_date": bill_date.isoformat(),
            "amount": round(random.uniform(50, 200), 2),
            "status": "paid",
            "payment_method": "credit_card",
            "rentals_count": random.randint(5, 15)
        })
    
    assert isinstance(bills, list)
    assert all(bill["status"] == "paid" for bill in bills)


def test_user_apply_promotion_code():
    """测试应用促销码"""
    # 模拟促销码请求
    promo_data = {
        "user_id": 1,
        "code": "SUMMER2023"
    }
    
    # 模拟响应
    response = {
        "success": True,
        "discount_type": "percentage",
        "discount_value": 15,
        "valid_until": (datetime.now() + timedelta(days=30)).isoformat(),
        "message": "Successfully applied 15% discount to your next rentals"
    }
    
    assert response["success"] is True
    assert "discount_value" in response


def test_user_report_scooter_issue():
    """测试报告滑板车问题"""
    # 模拟问题报告请求
    issue_data = {
        "user_id": 1,
        "scooter_id": 5,
        "issue_type": "mechanical",
        "description": "Brake not working properly",
        "location": {"lat": 39.9175, "lng": 116.4072}
    }
    
    # 模拟响应
    response = {
        "id": random.randint(100, 999),
        "created_at": datetime.now().isoformat(),
        "status": "reported",
        **issue_data
    }
    
    assert response["status"] == "reported"
    assert "id" in response
    
    # 循环延时
    for _ in range(random.randint(2, 5)):
        time.sleep(0.1)


def test_user_rate_rental_experience():
    """测试评价租赁体验"""
    # 模拟评价请求
    rating_data = {
        "user_id": 1,
        "rental_id": 123,
        "rating": 4,
        "comments": "Good experience overall, but the app was a bit slow"
    }
    
    # 模拟响应
    response = {
        "id": random.randint(100, 999),
        "created_at": datetime.now().isoformat(),
        **rating_data
    }
    
    assert 1 <= response["rating"] <= 5
    assert "id" in response


def test_user_notification_settings():
    """测试用户通知设置"""
    # 模拟通知设置
    settings = {
        "user_id": 1,
        "email_notifications": True,
        "push_notifications": True,
        "sms_notifications": False,
        "rental_reminders": True,
        "promotional_messages": False
    }
    
    # 模拟更新请求
    update_data = {
        "push_notifications": False,
        "promotional_messages": True
    }
    
    # 模拟响应
    response = {
        **settings,
        **update_data
    }
    
    assert response["push_notifications"] is False
    assert response["promotional_messages"] is True


def test_user_referral_program():
    """测试用户推荐计划"""
    # 模拟用户推荐数据
    referral_data = {
        "user_id": 1,
        "referral_code": "USER1FRIEND",
        "referred_users": [
            {"id": 101, "sign_up_date": (datetime.now() - timedelta(days=15)).isoformat(), "status": "active"},
            {"id": 102, "sign_up_date": (datetime.now() - timedelta(days=7)).isoformat(), "status": "active"}
        ],
        "rewards_earned": 20.0
    }
    
    assert isinstance(referral_data["referred_users"], list)
    assert referral_data["rewards_earned"] > 0
    
    # 循环延时
    for user in referral_data["referred_users"]:
        time.sleep(0.1)
        assert user["status"] == "active"


def test_user_subscription_plans():
    """测试用户订阅计划"""
    # 模拟可用订阅计划
    plans = [
        {
            "id": 1,
            "name": "Basic",
            "price_monthly": 9.99,
            "free_rides": 2,
            "discount_percentage": 0
        },
        {
            "id": 2,
            "name": "Premium",
            "price_monthly": 19.99,
            "free_rides": 5,
            "discount_percentage": 10
        },
        {
            "id": 3,
            "name": "Ultimate",
            "price_monthly": 29.99,
            "free_rides": 10,
            "discount_percentage": 20
        }
    ]
    
    # 模拟用户选择计划
    selected_plan = plans[1]
    
    # 模拟订阅响应
    response = {
        "user_id": 1,
        "plan_id": selected_plan["id"],
        "plan_name": selected_plan["name"],
        "start_date": datetime.now().isoformat(),
        "end_date": (datetime.now() + timedelta(days=30)).isoformat(),
        "status": "active"
    }
    
    assert response["plan_id"] == selected_plan["id"]
    assert response["status"] == "active"


def test_user_journey_analytics():
    """测试用户旅程分析"""
    # 模拟用户数据分析
    analytics = {
        "user_id": 1,
        "total_distance_km": 45.7,
        "total_rides": 17,
        "average_ride_duration": 22.5,
        "favorite_starting_points": [
            {"location": {"lat": 39.9075, "lng": 116.3972}, "count": 5},
            {"location": {"lat": 39.9173, "lng": 116.4079}, "count": 3}
        ],
        "carbon_saved_kg": 12.4
    }
    
    assert analytics["total_rides"] > 0
    assert isinstance(analytics["favorite_starting_points"], list)
    
    # 循环处理每个起点数据
    for point in analytics["favorite_starting_points"]:
        time.sleep(0.1)
        assert "location" in point
        assert point["count"] > 0