from sqlalchemy.orm import Session

from app.crud.rental_config import rental_config
from app.schemas.rental_config import RentalConfigCreate, RentalConfigUpdate


def test_create_rental_config(db: Session):
    # 创建租赁配置
    config_in = RentalConfigCreate(
        base_hourly_rate=20.0,
        period_discounts={"1hr": 1.0, "4hrs": 0.9, "1day": 0.8, "1week": 0.7},
    )

    db_config = rental_config.create_with_deactivate_others(db=db, obj_in=config_in)

    assert db_config.base_hourly_rate == config_in.base_hourly_rate
    assert db_config.period_discounts == config_in.period_discounts


def test_deactivate_other_configs(db: Session):
    # 创建多个配置
    configs = [
        RentalConfigCreate(
            base_hourly_rate=rate,
            period_discounts={"1hr": 1.0},
        )
        for rate in [20.0, 25.0, 30.0]
    ]

    for config in configs:
        rental_config.create_with_deactivate_others(db=db, obj_in=config)

    # 验证只有最后一个配置是激活状态
    all_configs = rental_config.get_all_configs(db)
    active_configs = [c for c in all_configs if c.is_active]

    assert len(active_configs) == 1
    assert active_configs[0].base_hourly_rate == 30.0


def test_create_config_with_minimum_rate(db: Session):
    """测试创建最小费率的配置"""
    config_in = RentalConfigCreate(
        base_hourly_rate=1.0,
        period_discounts={"1hr": 1.0},
    )
    db_config = rental_config.create_with_deactivate_others(db=db, obj_in=config_in)
    
    assert db_config.base_hourly_rate == 1.0
    assert db_config.is_active == True


def test_create_config_with_maximum_rate(db: Session):
    """测试创建最大费率的配置"""
    config_in = RentalConfigCreate(
        base_hourly_rate=9999.0,
        period_discounts={"1hr": 1.0},
    )
    db_config = rental_config.create_with_deactivate_others(db=db, obj_in=config_in)
    
    assert db_config.base_hourly_rate == 9999.0
    assert db_config.is_active == True


def test_create_config_with_empty_discounts(db: Session):
    """测试创建带空折扣的配置"""
    config_in = RentalConfigCreate(
        base_hourly_rate=50.0,
        period_discounts={},
    )
    db_config = rental_config.create_with_deactivate_others(db=db, obj_in=config_in)
    
    assert db_config.base_hourly_rate == 50.0
    assert db_config.period_discounts == {}
    assert db_config.is_active == True



def test_active_config_after_creation(db: Session):
    """测试创建后检查活跃配置"""
    # 先创建一个配置
    config_in1 = RentalConfigCreate(
        base_hourly_rate=25.0,
        period_discounts={"1hr": 1.0},
    )
    rental_config.create_with_deactivate_others(db=db, obj_in=config_in1)
    
    # 再创建一个配置
    config_in2 = RentalConfigCreate(
        base_hourly_rate=30.0,
        period_discounts={"1hr": 1.0},
    )
    rental_config.create_with_deactivate_others(db=db, obj_in=config_in2)
    
    # 获取所有配置并验证只有最新的是激活状态
    all_configs = rental_config.get_all_configs(db)
    active_config = next((c for c in all_configs if c.is_active), None)
    
    assert active_config is not None
    assert active_config.base_hourly_rate == 30.0


def test_create_and_verify_discount_values(db: Session):
    """测试创建并验证折扣值"""
    config_in = RentalConfigCreate(
        base_hourly_rate=40.0,
        period_discounts={"1hr": 1.0, "4hrs": 0.85, "1day": 0.75, "1week": 0.6},
    )
    db_config = rental_config.create_with_deactivate_others(db=db, obj_in=config_in)
    
    assert db_config.period_discounts["1hr"] == 1.0
    assert db_config.period_discounts["4hrs"] == 0.85
    assert db_config.period_discounts["1day"] == 0.75
    assert db_config.period_discounts["1week"] == 0.6


def test_check_inactive_configs(db: Session):
    """测试检查非活跃配置"""
    # 创建三个配置
    for rate in [60.0, 70.0, 80.0]:
        config_in = RentalConfigCreate(
            base_hourly_rate=rate,
            period_discounts={"1hr": 1.0},
        )
        rental_config.create_with_deactivate_others(db=db, obj_in=config_in)
    
    # 验证前两个配置是非活跃的
    all_configs = rental_config.get_all_configs(db)
    inactive_configs = [c for c in all_configs if not c.is_active]
    
    # 至少应该有2个非活跃配置
    assert len(inactive_configs) >= 2
    # 所有费率为60.0和70.0的配置都应该是非活跃的
    for config in inactive_configs:
        assert config.base_hourly_rate != 80.0


def test_create_config_with_fractional_rate(db: Session):
    """测试创建小数费率的配置"""
    config_in = RentalConfigCreate(
        base_hourly_rate=45.75,
        period_discounts={"1hr": 1.0},
    )
    db_config = rental_config.create_with_deactivate_others(db=db, obj_in=config_in)
    
    assert db_config.base_hourly_rate == 45.75
    assert db_config.is_active == True
