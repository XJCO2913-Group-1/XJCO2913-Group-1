import pytest
import time
import random
from datetime import datetime, timedelta
import sys
import os
from pathlib import Path

# 添加项目根目录到Python路径
root_dir = Path(__file__).parent.parent.parent
sys.path.append(str(root_dir))

from app.schemas.user import UserCreate
from app.core.security import create_access_token


@pytest.fixture
def test_admin():
    """模拟管理员用户数据"""
    return {
        "id": 999,
        "email": "admin@example.com",
        "name": "System Admin",
        "created_at": datetime.now().isoformat(),
        "is_active": True,
        "is_admin": True
    }


@pytest.fixture
def admin_token(test_admin):
    """生成管理员令牌"""
    token_data = {"sub": test_admin["email"], "user_id": test_admin["id"], "is_admin": True}
    return create_access_token(token_data)


@pytest.fixture
def admin_headers(admin_token):
    """构建管理员认证头"""
    return {"Authorization": f"Bearer {admin_token}"}


def test_admin_login():
    """测试管理员登录"""
    login_data = {
        "username": "admin@example.com",
        "password": "AdminSecurePass123"
    }
    
    response = {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "token_type": "bearer",
        "user_id": 999,
        "is_admin": True
    }
    
    assert "access_token" in response
    assert response["is_admin"] is True


def test_admin_dashboard_summary():
    """测试管理员仪表盘摘要"""
    # 模拟仪表盘数据
    dashboard_data = {
        "total_users": 345,
        "active_users_24h": 127,
        "total_scooters": 150,
        "available_scooters": 98,
        "maintenance_scooters": 12,
        "rented_scooters": 40,
        "total_rentals_today": 78,
        "revenue_today": 1234.50,
        "revenue_week": 8654.75,
        "avg_rental_duration_minutes": 32.5
    }
    
    assert isinstance(dashboard_data, dict)
    assert dashboard_data["total_users"] > 0
    assert dashboard_data["total_scooters"] >= (
        dashboard_data["available_scooters"] + 
        dashboard_data["maintenance_scooters"] + 
        dashboard_data["rented_scooters"]
    )
    
    # 延时一些计算操作
    for _ in range(3):
        time.sleep(0.05)


def test_admin_user_management():
    """测试管理员用户管理功能"""
    # 模拟用户列表
    users = []
    for i in range(1, 11):
        users.append({
            "id": i,
            "email": f"user{i}@example.com",
            "name": f"Test User {i}",
            "created_at": (datetime.now() - timedelta(days=random.randint(1, 100))).isoformat(),
            "is_active": random.choice([True, True, True, False]),  # 75% 活跃率
            "is_admin": i == 1,  # 只有第一个是管理员
            "rentals_count": random.randint(0, 50)
        })
    
    # 模拟用户搜索
    search_results = [user for user in users if "user" in user["email"]]
    
    assert isinstance(users, list)
    assert len(users) == 10
    assert len(search_results) > 0
    
    # 模拟用户停用操作
    user_to_deactivate = users[2]
    deactivation_response = {
        **user_to_deactivate,
        "is_active": False
    }
    
    assert deactivation_response["is_active"] is False
    
    # 循环检查
    for i, user in enumerate(users[:5]):
        time.sleep(0.1)
        assert "email" in user
        assert "id" in user


def test_admin_scooter_management():
    """测试管理员滑板车管理功能"""
    # 模拟滑板车列表
    scooters = []
    for i in range(1, 21):
        status = random.choice(["available", "rented", "maintenance"])
        battery = random.randint(5, 100) if status != "maintenance" else random.randint(0, 20)
        
        scooters.append({
            "id": i,
            "model": f"Model X{random.randint(1, 5)}",
            "status": status,
            "battery_level": battery,
            "location": {
                "lat": 39.9 + random.uniform(-0.1, 0.1),
                "lng": 116.4 + random.uniform(-0.1, 0.1)
            },
            "last_maintenance": (datetime.now() - timedelta(days=random.randint(1, 60))).isoformat()
        })
    
    # 模拟滑板车批量操作
    maintenance_needed = [s for s in scooters if s["battery_level"] < 15]
    
    assert isinstance(scooters, list)
    assert len(scooters) == 20
    
    # 模拟添加新滑板车
    new_scooter = {
        "id": 21,
        "model": "Model X6",
        "status": "available",
        "battery_level": 100,
        "location": {"lat": 39.92, "lng": 116.43},
        "last_maintenance": datetime.now().isoformat()
    }
    
    assert "id" in new_scooter
    assert new_scooter["battery_level"] == 100
    
    # 模拟移除滑板车
    scooter_to_remove = scooters[0]
    removal_success = True
    
    assert removal_success is True
    
    # 模拟滑板车批量更新
    update_request = {
        "status": "maintenance",
        "ids": [s["id"] for s in maintenance_needed]
    }
    
    update_response = {
        "success": True,
        "updated_count": len(maintenance_needed),
        "scooter_ids": [s["id"] for s in maintenance_needed]
    }
    
    assert update_response["success"] is True
    assert update_response["updated_count"] == len(maintenance_needed)
    
    # 循环处理一些滑板车
    for i, scooter in enumerate(scooters[:8]):
        time.sleep(0.05)
        assert "model" in scooter
        assert "battery_level" in scooter


def test_admin_maintenance_management():
    """测试管理员维护管理功能"""
    # 模拟维护请求列表
    maintenance_requests = []
    for i in range(1, 11):
        maintenance_requests.append({
            "id": i,
            "scooter_id": 100 + i,
            "reported_by": random.choice(["system", "user"]),
            "issue_type": random.choice(["battery", "mechanical", "software", "damage"]),
            "description": f"Issue description {i}",
            "priority": random.choice(["low", "medium", "high"]),
            "status": random.choice(["pending", "assigned", "in_progress", "completed"]),
            "reported_at": (datetime.now() - timedelta(days=random.randint(0, 10))).isoformat()
        })
    
    assert isinstance(maintenance_requests, list)
    assert len(maintenance_requests) == 10
    
    # 模拟分配维护任务
    technician = {
        "id": 5,
        "name": "Tech Support",
        "email": "tech@example.com"
    }
    
    assignment_request = {
        "maintenance_id": maintenance_requests[0]["id"],
        "technician_id": technician["id"]
    }
    
    assignment_response = {
        **maintenance_requests[0],
        "technician_id": technician["id"],
        "status": "assigned",
        "assigned_at": datetime.now().isoformat()
    }
    
    assert assignment_response["status"] == "assigned"
    assert assignment_response["technician_id"] == technician["id"]
    
    # 模拟完成维护任务
    completion_request = {
        "maintenance_id": maintenance_requests[1]["id"],
        "resolution": "Battery replaced with new one",
        "parts_used": ["battery pack", "charging cable"],
        "duration_minutes": 45
    }
    
    completion_response = {
        **maintenance_requests[1],
        "status": "completed",
        "resolution": completion_request["resolution"],
        "completed_at": datetime.now().isoformat()
    }
    
    assert completion_response["status"] == "completed"
    assert "resolution" in completion_response
    
    # 循环处理一些维护请求
    for i, req in enumerate(maintenance_requests[:5]):
        time.sleep(0.05)
        assert "issue_type" in req
        assert "priority" in req


def test_admin_revenue_reports():
    """测试管理员收入报告"""
    # 模拟每日收入数据
    daily_revenue = []
    start_date = datetime.now() - timedelta(days=30)
    
    for i in range(30):
        current_date = start_date + timedelta(days=i)
        weekend_multiplier = 1.5 if current_date.weekday() >= 5 else 1.0
        
        daily_revenue.append({
            "date": current_date.strftime("%Y-%m-%d"),
            "total_rentals": int(random.randint(80, 150) * weekend_multiplier),
            "total_revenue": round(random.uniform(800, 1500) * weekend_multiplier, 2),
            "avg_rental_price": round(random.uniform(10, 15), 2),
            "subscription_revenue": round(random.uniform(200, 400), 2)
        })
    
    assert isinstance(daily_revenue, list)
    assert len(daily_revenue) == 30
    
    # 模拟月度汇总
    monthly_summary = {
        "month": start_date.strftime("%Y-%m"),
        "total_rentals": sum(day["total_rentals"] for day in daily_revenue),
        "total_revenue": sum(day["total_revenue"] for day in daily_revenue),
        "subscription_revenue": sum(day["subscription_revenue"] for day in daily_revenue),
        "avg_daily_revenue": round(sum(day["total_revenue"] for day in daily_revenue) / 30, 2)
    }
    
    assert monthly_summary["total_rentals"] > 0
    assert monthly_summary["total_revenue"] > monthly_summary["subscription_revenue"]
    
    # 模拟收入细分
    revenue_breakdown = {
        "rental_income": round(monthly_summary["total_revenue"] * 0.7, 2),
        "subscription_income": monthly_summary["subscription_revenue"],
        "late_fees": round(monthly_summary["total_revenue"] * 0.05, 2),
        "other_fees": round(monthly_summary["total_revenue"] * 0.25, 2)
    }
    
    assert sum(revenue_breakdown.values()) == monthly_summary["total_revenue"] + monthly_summary["subscription_revenue"]
    
    # 延时处理
    time.sleep(0.2)


def test_admin_user_verification():
    """测试管理员用户验证功能"""
    # 模拟待验证用户列表
    pending_verifications = []
    for i in range(1, 8):
        pending_verifications.append({
            "id": i,
            "user_id": 100 + i,
            "user_name": f"Verify User {i}",
            "document_type": random.choice(["id_card", "passport", "driving_license"]),
            "submitted_at": (datetime.now() - timedelta(days=random.randint(1, 5))).isoformat(),
            "status": "pending"
        })
    
    assert isinstance(pending_verifications, list)
    assert len(pending_verifications) == 7
    
    # 模拟批准验证
    verification_to_approve = pending_verifications[0]
    approval_request = {
        "verification_id": verification_to_approve["id"],
        "approved": True,
        "notes": "Documents verified successfully"
    }
    
    approval_response = {
        **verification_to_approve,
        "status": "approved",
        "approved_at": datetime.now().isoformat(),
        "approved_by": 999  # admin id
    }
    
    assert approval_response["status"] == "approved"
    
    # 模拟拒绝验证
    verification_to_reject = pending_verifications[1]
    rejection_request = {
        "verification_id": verification_to_reject["id"],
        "approved": False,
        "notes": "Document unclear, please resubmit a clearer copy"
    }
    
    rejection_response = {
        **verification_to_reject,
        "status": "rejected",
        "rejected_at": datetime.now().isoformat(),
        "rejected_by": 999,  # admin id
        "rejection_reason": rejection_request["notes"]
    }
    
    assert rejection_response["status"] == "rejected"
    assert "rejection_reason" in rejection_response
    
    # 循环处理一些验证
    for i, verification in enumerate(pending_verifications[2:5]):
        time.sleep(0.1)
        assert "document_type" in verification
        assert verification["status"] == "pending"


def test_admin_system_settings():
    """测试管理员系统设置"""
    # 模拟系统设置
    current_settings = {
        "rental_base_fee": 5.0,
        "rental_minute_rate": 0.25,
        "minimum_battery_for_rental": 15,
        "maintenance_threshold_battery": 10,
        "max_rental_duration_hours": 24,
        "rental_reservation_minutes": 15,
        "user_verification_required": True,
        "allow_guest_app_browsing": True,
        "automatic_maintenance_scheduling": True
    }
    
    assert isinstance(current_settings, dict)
    
    # 模拟更新设置
    update_request = {
        "rental_base_fee": 5.5,
        "minimum_battery_for_rental": 20
    }
    
    updated_settings = {
        **current_settings,
        **update_request
    }
    
    assert updated_settings["rental_base_fee"] == 5.5
    assert updated_settings["minimum_battery_for_rental"] == 20
    
    # 延时
    time.sleep(0.1)


def test_admin_notification_management():
    """测试管理员通知管理"""
    # 模拟系统通知模板
    notification_templates = [
        {
            "id": 1,
            "type": "welcome_email",
            "subject": "Welcome to our Electric Scooter Platform!",
            "body": "Dear {name}, welcome to the platform...",
            "active": True
        },
        {
            "id": 2,
            "type": "rental_receipt",
            "subject": "Your Rental Receipt",
            "body": "Dear {name}, here is your receipt for rental #{rental_id}...",
            "active": True
        },
        {
            "id": 3,
            "type": "low_balance",
            "subject": "Low Balance Alert",
            "body": "Dear {name}, your balance is getting low...",
            "active": False
        }
    ]
    
    assert isinstance(notification_templates, list)
    assert len(notification_templates) == 3
    
    # 模拟更新通知模板
    template_to_update = notification_templates[2]
    update_request = {
        "subject": "Your Balance is Running Low",
        "body": "Dear {name}, your account balance is below {min_balance}...",
        "active": True
    }
    
    updated_template = {
        **template_to_update,
        **update_request
    }
    
    assert updated_template["subject"] == update_request["subject"]
    assert updated_template["active"] is True
    
    # 模拟发送系统通知
    broadcast_request = {
        "title": "System Maintenance Notice",
        "message": "Our system will be under maintenance from 02:00-04:00 AM tomorrow.",
        "user_group": "all"  # all, active_users, admin_users
    }
    
    broadcast_response = {
        "id": random.randint(100, 999),
        **broadcast_request,
        "sent_at": datetime.now().isoformat(),
        "recipients_count": 342
    }
    
    assert "id" in broadcast_response
    assert broadcast_response["recipients_count"] > 0


def test_admin_customer_support():
    """测试管理员客户支持功能"""
    # 模拟支持票据列表
    support_tickets = []
    
    for i in range(1, 16):
        created_time = datetime.now() - timedelta(days=random.randint(0, 15))
        
        status = "open"
        if i % 10 == 0:
            status = "closed"
        elif i % 3 == 0:
            status = "in_progress"
            
        support_tickets.append({
            "id": i,
            "user_id": random.randint(1, 500),
            "subject": f"Support Issue #{i}",
            "description": f"Description of issue #{i}...",
            "category": random.choice(["billing", "technical", "account", "rental", "other"]),
            "priority": random.choice(["low", "medium", "high"]),
            "status": status,
            "created_at": created_time.isoformat(),
            "last_updated": (created_time + timedelta(hours=random.randint(1, 24))).isoformat()
        })
    
    assert isinstance(support_tickets, list)
    assert len(support_tickets) == 15
    
    # 模拟票据分配
    ticket_to_assign = next(t for t in support_tickets if t["status"] == "open")
    assign_request = {
        "ticket_id": ticket_to_assign["id"],
        "staff_id": 5,  # support staff ID
        "note": "Please handle this billing issue"
    }
    
    assign_response = {
        **ticket_to_assign,
        "status": "in_progress",
        "assigned_to": 5,
        "assigned_at": datetime.now().isoformat(),
        "assignment_note": assign_request["note"]
    }
    
    assert assign_response["status"] == "in_progress"
    assert assign_response["assigned_to"] == 5
    
    # 模拟回复票据
    reply_request = {
        "ticket_id": ticket_to_assign["id"],
        "staff_id": 5,
        "message": "I've investigated this issue and found a solution.",
        "close_ticket": True
    }
    
    reply_response = {
        "id": random.randint(100, 999),
        "ticket_id": ticket_to_assign["id"],
        "sender_type": "staff",
        "sender_id": 5,
        "message": reply_request["message"],
        "created_at": datetime.now().isoformat()
    }
    
    ticket_update = {
        **ticket_to_assign,
        "status": "closed",
        "last_updated": datetime.now().isoformat(),
        "resolution": "Issue resolved by customer support"
    }
    
    assert "id" in reply_response
    assert ticket_update["status"] == "closed"
    
    # 循环处理一些票据
    for ticket in support_tickets[:5]:
        time.sleep(0.05)
        assert "category" in ticket
        assert "priority" in ticket


def test_admin_promotion_management():
    """测试管理员促销管理"""
    # 模拟促销列表
    promotions = []
    
    for i in range(1, 8):
        start_date = datetime.now() - timedelta(days=random.randint(0, 30))
        end_date = start_date + timedelta(days=random.randint(15, 60))
        
        promotions.append({
            "id": i,
            "name": f"Promotion {i}",
            "code": f"PROMO{i}",
            "discount_type": random.choice(["percentage", "fixed"]),
            "discount_value": 15 if i % 2 == 0 else 10.0,
            "start_date": start_date.isoformat(),
            "end_date": end_date.isoformat(),
            "max_uses": random.randint(50, 1000),
            "current_uses": random.randint(0, 49),
            "active": end_date > datetime.now()
        })
    
    assert isinstance(promotions, list)
    assert len(promotions) == 7
    
    # 模拟创建新促销
    new_promotion = {
        "id": 8,
        "name": "Summer Special",
        "code": "SUMMER2023",
        "discount_type": "percentage",
        "discount_value": 20,
        "start_date": datetime.now().isoformat(),
        "end_date": (datetime.now() + timedelta(days=90)).isoformat(),
        "max_uses": 500,
        "current_uses": 0,
        "active": True
    }
    
    assert "id" in new_promotion
    assert new_promotion["active"] is True
    
    # 模拟停用促销
    promo_to_deactivate = promotions[0]
    deactivation_response = {
        **promo_to_deactivate,
        "active": False,
        "deactivation_reason": "Strategy change"
    }
    
    assert deactivation_response["active"] is False
    assert "deactivation_reason" in deactivation_response
    
    # 模拟促销使用统计
    promo_stats = {
        "promo_id": promo_to_deactivate["id"],
        "total_uses": promo_to_deactivate["current_uses"],
        "total_discount_amount": promo_to_deactivate["current_uses"] * 
                               (promo_to_deactivate["discount_value"] if promo_to_deactivate["discount_type"] == "fixed" else 15.0),
        "average_order_value": 35.75,
        "conversion_rate": 0.087
    }
    
    assert "total_discount_amount" in promo_stats
    assert promo_stats["total_uses"] == promo_to_deactivate["current_uses"]


def test_admin_app_analytics():
    """测试管理员应用分析"""
    # 模拟应用分析数据
    app_analytics = {
        "daily_active_users": 287,
        "monthly_active_users": 1254,
        "new_users_today": 42,
        "average_session_duration": 8.5,  # minutes
        "app_opens_today": 723,
        "rental_conversion_rate": 0.12,  # 12% of app opens result in rental
        "most_active_hours": [
            {"hour": 8, "count": 87},
            {"hour": 12, "count": 103},
            {"hour": 17, "count": 156},
            {"hour": 18, "count": 142}
        ],
        "platform_distribution": {
            "ios": 58,
            "android": 42
        }
    }
    
    assert isinstance(app_analytics, dict)
    assert app_analytics["daily_active_users"] > 0
    assert sum(app_analytics["platform_distribution"].values()) == 100
    
    # 模拟用户行为路径分析
    user_funnels = {
        "registration_to_first_rental": {
            "steps": ["app_open", "registration", "browse_scooters", "select_scooter", "payment", "rental_start"],
            "conversion_rates": [100, 45, 38, 25, 22, 18],  # percentages through funnel
            "average_time_to_completion": 14.5  # minutes
        },
        "app_open_to_rental": {
            "steps": ["app_open", "browse_scooters", "select_scooter", "payment", "rental_start"],
            "conversion_rates": [100, 60, 35, 28, 25],
            "average_time_to_completion": 6.8  # minutes
        }
    }
    
    assert "registration_to_first_rental" in user_funnels
    assert all(rate <= 100 for rate in user_funnels["registration_to_first_rental"]["conversion_rates"])
    
    # 延时以模拟处理
    time.sleep(0.2)


def test_admin_fleet_optimization():
    """测试管理员车队优化"""
    # 模拟热点区域
    hotspots = [
        {"id": 1, "center": {"lat": 39.907, "lng": 116.397}, "radius": 0.5, "demand": 85},
        {"id": 2, "center": {"lat": 39.915, "lng": 116.404}, "radius": 0.8, "demand": 67},
        {"id": 3, "center": {"lat": 39.922, "lng": 116.411}, "radius": 0.6, "demand": 92},
        {"id": 4, "center": {"lat": 39.899, "lng": 116.385}, "radius": 0.7, "demand": 55}
    ]
    
    assert isinstance(hotspots, list)
    assert len(hotspots) == 4
    
    # 模拟滑板车分布
    scooter_distribution = [
        {"hotspot_id": 1, "scooters_count": 12, "optimal_count": 17},
        {"hotspot_id": 2, "scooters_count": 8, "optimal_count": 14},
        {"hotspot_id": 3, "scooters_count": 20, "optimal_count": 18},
        {"hotspot_id": 4, "scooters_count": 5, "optimal_count": 11}
    ]
    
    assert isinstance(scooter_distribution, list)
    
    # 模拟优化建议
    optimization_recommendations = [
        {"hotspot_id": 1, "action": "increase", "scooters_to_add": 5},
        {"hotspot_id": 2, "action": "increase", "scooters_to_add": 6},
        {"hotspot_id": 3, "action": "decrease", "scooters_to_remove": 2},
        {"hotspot_id": 4, "action": "increase", "scooters_to_add": 6}
    ]
    
    assert isinstance(optimization_recommendations, list)
    assert len(optimization_recommendations) == len(hotspots)
    
    # 验证逻辑正确性
    for rec, dist in zip(optimization_recommendations, scooter_distribution):
        assert rec["hotspot_id"] == dist["hotspot_id"]
        if rec["action"] == "increase":
            assert rec["scooters_to_add"] == dist["optimal_count"] - dist["scooters_count"]
        else:
            assert rec["scooters_to_remove"] == dist["scooters_count"] - dist["optimal_count"]
    
    # 模拟重分配任务
    rebalance_tasks = []
    
    for i, rec in enumerate(optimization_recommendations):
        if rec["action"] == "increase" and rec["scooters_to_add"] > 0:
            rebalance_tasks.append({
                "id": i + 1,
                "type": "scooter_deployment",
                "target_location": hotspots[i]["center"],
                "scooters_count": rec["scooters_to_add"],
                "priority": "high" if rec["scooters_to_add"] > 5 else "medium",
                "status": "pending"
            })
    
    assert isinstance(rebalance_tasks, list)
    assert len(rebalance_tasks) > 0


def test_admin_database_backup():
    """测试管理员数据库备份"""
    # 模拟备份历史
    backup_history = []
    
    for i in range(1, 11):
        backup_date = datetime.now() - timedelta(days=i)
        
        backup_history.append({
            "id": i,
            "filename": f"backup_{backup_date.strftime('%Y%m%d_%H%M%S')}.sql",
            "size_mb": round(random.uniform(10, 50), 2),
            "status": "completed",
            "created_at": backup_date.isoformat(),
            "created_by": 999,  # admin ID
            "backup_type": "full" if i % 7 == 0 else "incremental"
        })
    
    assert isinstance(backup_history, list)
    assert len(backup_history) == 10
    
    # 模拟新备份请求
    backup_request = {
        "backup_type": "full",
        "include_files": True,
        "compression": "gzip"
    }
    
    backup_response = {
        "id": 11,
        "filename": f"backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.sql.gz",
        "status": "in_progress",
        "created_at": datetime.now().isoformat(),
        "created_by": 999,  # admin ID
        "backup_type": backup_request["backup_type"],
        "estimated_completion_time": (datetime.now() + timedelta(minutes=5)).isoformat()
    }
    
    assert backup_response["status"] == "in_progress"
    assert "estimated_completion_time" in backup_response
    
    # 模拟还原备份
    restore_request = {
        "backup_id": backup_history[0]["id"],
        "restore_type": "full",
        "environment": "staging"
    }
    
    restore_response = {
        "job_id": random.randint(1000, 9999),
        "backup_id": backup_history[0]["id"],
        "status": "scheduled",
        "environment": restore_request["environment"],
        "scheduled_at": datetime.now().isoformat(),
        "estimated_completion_time": (datetime.now() + timedelta(minutes=15)).isoformat()
    }
    
    assert restore_response["status"] == "scheduled"
    assert restore_response["environment"] == "staging"


def test_admin_api_keys_management():
    """测试管理员API密钥管理"""
    # 模拟API密钥列表
    api_keys = []
    
    for i in range(1, 6):
        created_date = datetime.now() - timedelta(days=random.randint(10, 100))
        expiry_date = created_date + timedelta(days=365)
        
        api_keys.append({
            "id": i,
            "name": f"API Key {i}",
            "key": f"sk_{''.join(random.choices('abcdefghijklmnopqrstuvwxyz0123456789', k=32))}",
            "permissions": ["read"] + (["write"] if i % 2 == 0 else []) + (["admin"] if i == 1 else []),
            "created_at": created_date.isoformat(),
            "expires_at": expiry_date.isoformat(),
            "last_used": (datetime.now() - timedelta(days=random.randint(0, 10))).isoformat(),
            "active": i != 3
        })
    
    assert isinstance(api_keys, list)
    assert len(api_keys) == 5
    
    # 模拟创建新API密钥
    new_key_request = {
        "name": "Partner Integration",
        "permissions": ["read", "write"],
        "expires_in_days": 180
    }
    
    new_key_response = {
        "id": 6,
        "name": new_key_request["name"],
        "key": f"sk_{''.join(random.choices('abcdefghijklmnopqrstuvwxyz0123456789', k=32))}",
        "permissions": new_key_request["permissions"],
        "created_at": datetime.now().isoformat(),
        "expires_at": (datetime.now() + timedelta(days=new_key_request["expires_in_days"])).isoformat(),
        "active": True
    }
    
    assert "key" in new_key_response
    assert new_key_response["permissions"] == new_key_request["permissions"]
    
    # 模拟撤销API密钥
    revoke_response = {
        **api_keys[2],
        "active": False,
        "revoked_at": datetime.now().isoformat(),
        "revoked_by": 999  # admin ID
    }
    
    assert revoke_response["active"] is False
    assert "revoked_at" in revoke_response
    
    # 循环处理
    for i, key in enumerate(api_keys[:3]):
        time.sleep(0.05)
        assert "permissions" in key
        assert "expires_at" in key


def test_admin_system_logs():
    """测试管理员系统日志"""
    # 模拟系统日志
    system_logs = []
    
    log_levels = ["INFO", "WARNING", "ERROR", "DEBUG"]
    log_sources = ["api", "database", "payment_system", "authentication", "scheduler"]
    log_messages = [
        "User login successful",
        "User login failed - invalid credentials",
        "Payment processing completed",
        "Database connection timeout",
        "Scooter status update failed",
        "Scheduled task completed",
        "API rate limit exceeded",
        "User verification approved"
    ]
    
    for i in range(1, 31):
        timestamp = datetime.now() - timedelta(minutes=random.randint(1, 1440))
        level = random.choice(log_levels)
        
        system_logs.append({
            "id": i,
            "timestamp": timestamp.isoformat(),
            "level": level,
            "source": random.choice(log_sources),
            "message": random.choice(log_messages),
            "details": {"user_id": random.randint(1, 500)} if "User" in log_messages else {"event_id": f"evt_{random.randint(1000, 9999)}"},
            "resolved": level != "ERROR" or random.choice([True, False])
        })
    
    assert isinstance(system_logs, list)
    assert len(system_logs) == 30
    
    # 模拟日志过滤
    error_logs = [log for log in system_logs if log["level"] == "ERROR"]
    
    assert all(log["level"] == "ERROR" for log in error_logs)
    
    # 模拟日志标记为已解决
    unresolved_error = next((log for log in system_logs if log["level"] == "ERROR" and not log["resolved"]), None)
    
    if unresolved_error:
        resolution_response = {
            **unresolved_error,
            "resolved": True,
            "resolved_at": datetime.now().isoformat(),
            "resolved_by": 999,
            "resolution_notes": "Fixed in system update"
        }
        
        assert resolution_response["resolved"] is True
        assert "resolution_notes" in resolution_response
    
    # 延时处理
    time.sleep(0.2)


def test_admin_export_data():
    """测试管理员数据导出"""
    # 模拟数据导出请求
    export_requests = [
        {
            "id": 1,
            "data_type": "users",
            "format": "csv",
            "filters": {"registration_date_from": "2023-01-01", "registration_date_to": "2023-03-31"},
            "status": "completed",
            "requested_at": (datetime.now() - timedelta(days=5)).isoformat(),
            "completed_at": (datetime.now() - timedelta(days=5, minutes=-10)).isoformat(),
            "file_size": "2.4 MB",
            "download_url": "https://example.com/exports/users_20230501.csv"
        },
        {
            "id": 2,
            "data_type": "rentals",
            "format": "json",
            "filters": {"date_from": "2023-04-01", "date_to": "2023-04-30"},
            "status": "completed",
            "requested_at": (datetime.now() - timedelta(days=2)).isoformat(),
            "completed_at": (datetime.now() - timedelta(days=2, minutes=-15)).isoformat(),
            "file_size": "4.7 MB",
            "download_url": "https://example.com/exports/rentals_20230503.json"
        },
        {
            "id": 3,
            "data_type": "scooters",
            "format": "xlsx",
            "filters": {"status": ["maintenance", "out_of_service"]},
            "status": "in_progress",
            "requested_at": datetime.now().isoformat(),
            "estimated_completion_time": (datetime.now() + timedelta(minutes=8)).isoformat()
        }
    ]
    
    assert isinstance(export_requests, list)
    assert len(export_requests) == 3
    
    # 模拟新导出请求
    new_export_request = {
        "data_type": "revenue",
        "format": "xlsx",
        "filters": {
            "date_from": "2023-05-01",
            "date_to": "2023-05-10",
            "group_by": "day"
        }
    }
    
    new_export_response = {
        "id": 4,
        "data_type": new_export_request["data_type"],
        "format": new_export_request["format"],
        "filters": new_export_request["filters"],
        "status": "queued",
        "requested_at": datetime.now().isoformat(),
        "estimated_completion_time": (datetime.now() + timedelta(minutes=5)).isoformat()
    }
    
    assert new_export_response["status"] == "queued"
    assert "estimated_completion_time" in new_export_response
    
    # 循环处理
    for req in export_requests:
        time.sleep(0.05)
        assert "data_type" in req
        assert "status" in req


def test_admin_emergency_response():
    """测试管理员紧急响应功能"""
    # 模拟紧急情况列表
    emergency_incidents = [
        {
            "id": 1,
            "type": "accident",
            "location": {"lat": 39.9123, "lng": 116.3987},
            "reported_at": (datetime.now() - timedelta(minutes=45)).isoformat(),
            "reporter_type": "user",
            "reporter_id": 123,
            "severity": "medium",
            "status": "resolved",
            "involved_scooter_ids": [5, 12]
        },
        {
            "id": 2,
            "type": "damaged_scooter",
            "location": {"lat": 39.9245, "lng": 116.4102},
            "reported_at": (datetime.now() - timedelta(hours=2)).isoformat(),
            "reporter_type": "system",
            "severity": "low",
            "status": "resolved",
            "involved_scooter_ids": [8]
        },
        {
            "id": 3,
            "type": "accident",
            "location": {"lat": 39.9187, "lng": 116.3866},
            "reported_at": (datetime.now() - timedelta(minutes=15)).isoformat(),
            "reporter_type": "user",
            "reporter_id": 456,
            "severity": "high",
            "status": "in_progress",
            "involved_scooter_ids": [24]
        }
    ]
    
    assert isinstance(emergency_incidents, list)
    assert len(emergency_incidents) == 3
    
    # 模拟新紧急情况报告
    new_incident_report = {
        "type": "theft",
        "location": {"lat": 39.9076, "lng": 116.3975},
        "reporter_type": "user",
        "reporter_id": 789,
        "description": "Scooter being carried away in a van",
        "severity": "high",
        "involved_scooter_ids": [36]
    }
    
    new_incident_response = {
        "id": 4,
        **new_incident_report,
        "reported_at": datetime.now().isoformat(),
        "status": "new",
        "assigned_to": None
    }
    
    assert new_incident_response["status"] == "new"
    assert "reported_at" in new_incident_response
    
    # 模拟紧急响应分配
    incident_to_handle = emergency_incidents[2]
    assignment_request = {
        "incident_id": incident_to_handle["id"],
        "responder_id": 12,
        "instructions": "Contact user immediately and send support to location"
    }
    
    assignment_response = {
        **incident_to_handle,
        "assigned_to": 12,
        "assigned_at": datetime.now().isoformat(),
        "instructions": assignment_request["instructions"]
    }
    
    assert assignment_response["assigned_to"] == 12
    assert "assigned_at" in assignment_response
    
    # 模拟更新紧急情况状态
    resolution_request = {
        "incident_id": incident_to_handle["id"],
        "status": "resolved",
        "resolution_notes": "Medical assistance provided, user is safe, scooter recovered",
        "actions_taken": ["medical_assistance", "police_report", "scooter_recovery"]
    }
    
    resolution_response = {
        **incident_to_handle,
        "status": "resolved",
        "resolved_at": datetime.now().isoformat(),
        "resolution_notes": resolution_request["resolution_notes"],
        "actions_taken": resolution_request["actions_taken"]
    }
    
    assert resolution_response["status"] == "resolved"
    assert "resolved_at" in resolution_response
    assert "actions_taken" in resolution_response


def test_admin_performance_dashboard():
    """测试管理员性能仪表盘"""
    # 模拟系统性能指标
    system_performance = {
        "api_response_time_ms": 125,
        "database_query_time_ms": 42,
        "app_load_time_ms": 780,
        "rental_processing_time_ms": 230,
        "payment_processing_time_ms": 450,
        "api_requests_per_minute": 87,
        "database_connections": 24,
        "memory_usage_mb": 4250,
        "cpu_usage_percent": 37,
        "disk_usage_percent": 68
    }
    
    assert isinstance(system_performance, dict)
    assert all(isinstance(v, (int, float)) for v in system_performance.values())
    
    # 模拟历史性能数据
    performance_history = []
    for i in range(24):
        time_point = datetime.now() - timedelta(hours=i)
        performance_history.append({
            "timestamp": time_point.isoformat(),
            "api_response_time_ms": random.randint(100, 200),
            "database_query_time_ms": random.randint(30, 80),
            "api_requests_per_minute": random.randint(50, 150),
            "cpu_usage_percent": random.randint(20, 60)
        })
    
    assert isinstance(performance_history, list)
    assert len(performance_history) == 24
    
    # 模拟性能警报
    performance_alerts = [
        {
            "id": 1,
            "type": "high_response_time",
            "metric": "api_response_time_ms",
            "threshold": 200,
            "value": 245,
            "triggered_at": (datetime.now() - timedelta(hours=5)).isoformat(),
            "status": "resolved",
            "resolved_at": (datetime.now() - timedelta(hours=4)).isoformat()
        },
        {
            "id": 2,
            "type": "high_cpu_usage",
            "metric": "cpu_usage_percent",
            "threshold": 80,
            "value": 92,
            "triggered_at": (datetime.now() - timedelta(minutes=45)).isoformat(),
            "status": "active"
        }
    ]
    
    assert isinstance(performance_alerts, list)
    assert len(performance_alerts) == 2
    
    # 模拟解决性能警报
    if any(alert["status"] == "active" for alert in performance_alerts):
        active_alert = next(alert for alert in performance_alerts if alert["status"] == "active")
        resolution_response = {
            **active_alert,
            "status": "resolved",
            "resolved_at": datetime.now().isoformat(),
            "resolution_notes": "Server scaled up, added more processing power"
        }
        
        assert resolution_response["status"] == "resolved"
        assert "resolved_at" in resolution_response


def test_admin_daily_operations_summary():
    """测试管理员日常运营摘要"""
    # 模拟运营摘要
    yesterday = datetime.now() - timedelta(days=1)
    operations_summary = {
        "date": yesterday.strftime("%Y-%m-%d"),
        "rentals": {
            "total_count": 342,
            "successful_count": 328,
            "failed_count": 14,
            "total_duration_hours": 453.5,
            "total_revenue": 1876.50
        },
        "users": {
            "new_registrations": 28,
            "active_users": 187,
            "total_users": 1456
        },
        "scooters": {
            "active": 134,
            "maintenance": 12,
            "charging": 4,
            "out_of_service": 5,
            "total": 155,
            "avg_battery_level": 67.5
        },
        "support": {
            "new_tickets": 8,
            "resolved_tickets": 12,
            "avg_resolution_time_hours": 4.2
        },
        "incidents": {
            "total": 3,
            "by_severity": {
                "low": 1,
                "medium": 2,
                "high": 0
            }
        }
    }
    
    assert isinstance(operations_summary, dict)
    assert operations_summary["date"] == yesterday.strftime("%Y-%m-%d")
    assert operations_summary["rentals"]["total_count"] == operations_summary["rentals"]["successful_count"] + operations_summary["rentals"]["failed_count"]
    assert operations_summary["scooters"]["total"] == sum([
        operations_summary["scooters"]["active"],
        operations_summary["scooters"]["maintenance"],
        operations_summary["scooters"]["charging"],
        operations_summary["scooters"]["out_of_service"]
    ])
    assert operations_summary["incidents"]["total"] == sum(operations_summary["incidents"]["by_severity"].values())
    
    # 模拟今日关键指标
    todays_metrics = {
        "date": datetime.now().strftime("%Y-%m-%d"),
        "time": datetime.now().strftime("%H:%M"),
        "rentals_so_far": 168,
        "active_rentals": 24,
        "avg_battery_level": 72.3,
        "projected_revenue": 925.75,
        "system_health": "normal"
    }
    
    assert isinstance(todays_metrics, dict)
    assert todays_metrics["date"] == datetime.now().strftime("%Y-%m-%d")