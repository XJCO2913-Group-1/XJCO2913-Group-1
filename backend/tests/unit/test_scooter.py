import pytest
from sqlalchemy.orm import Session
from app.models.scooter import Scooter

def test_create_scooter(db: Session):
    scooter = Scooter(
        model="Test Model",
        status="available",
        battery_level=100,
        location={"lat": 40.7128, "lng": -74.0060}
    )
    
    db.add(scooter)
    db.commit()
    db.refresh(scooter)
    
    assert scooter.model == "Test Model"
    assert scooter.status == "available"
    assert scooter.battery_level == 100
    assert scooter.location == {"lat": 40.7128, "lng": -74.0060}

def test_update_scooter_status(db: Session):
    scooter = Scooter(
        model="Test Model 2",
        status="available",
        battery_level=100,
        location={"lat": 40.7128, "lng": -74.0060}
    )
    
    db.add(scooter)
    db.commit()
    
    scooter.status = "in_use"
    scooter.battery_level = 80
    db.commit()
    db.refresh(scooter)
    
    assert scooter.status == "in_use"
    assert scooter.battery_level == 80