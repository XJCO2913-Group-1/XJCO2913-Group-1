import pytest
from sqlalchemy.orm import Session
from fastapi import HTTPException

from app.crud.scooter import scooter
from app.schemas.scooter import ScooterCreate, ScooterUpdate
from app.models.scooter import Scooter


def test_create_scooter(db: Session):
    scooter_in = ScooterCreate(
        model="Xiaomi M365",
        status="available",
        battery_level=100,
        location={"lat": 39.9891, "lng": 116.3176}
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)
    assert db_scooter.model == scooter_in.model
    assert db_scooter.status == scooter_in.status
    assert db_scooter.battery_level == scooter_in.battery_level
    assert db_scooter.location == scooter_in.location


def test_get_scooter(db: Session):
    scooter_in = ScooterCreate(
        model="Segway ES2",
        status="available",
        battery_level=90,
        location={"lat": 39.9087, "lng": 116.3914}
    )
    created_scooter = scooter.create(db=db, obj_in=scooter_in)
    
    fetched_scooter = scooter.get(db=db, id=created_scooter.id)
    assert fetched_scooter
    assert fetched_scooter.model == scooter_in.model
    assert fetched_scooter.status == scooter_in.status
    assert fetched_scooter.battery_level == scooter_in.battery_level
    assert fetched_scooter.location == scooter_in.location


def test_get_scooter_not_found(db: Session):
    fetched_scooter = scooter.get(db=db, id=999)
    assert fetched_scooter is None


def test_get_multi_scooters(db: Session):
    # Create multiple scooters
    scooter_data = [
        ScooterCreate(
            model="Xiaomi M365",
            status="available",
            battery_level=100,
            location={"lat": 39.9891, "lng": 116.3176}
        ),
        ScooterCreate(
            model="Ninebot Max",
            status="maintenance",
            battery_level=50,
            location={"lat": 39.9219, "lng": 116.4402}
        )
    ]
    
    for scooter_in in scooter_data:
        scooter.create(db=db, obj_in=scooter_in)
    
    scooters = scooter.get_multi(db=db)
    assert len(scooters) == 2
    assert all(isinstance(s, Scooter) for s in scooters)


def test_update_scooter(db: Session):
    # Create a scooter first
    scooter_in = ScooterCreate(
        model="Xiaomi Pro 2",
        status="available",
        battery_level=85,
        location={"lat": 39.9175, "lng": 116.4076}
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)
    
    # Update the scooter
    scooter_update = ScooterUpdate(
        status="maintenance",
        battery_level=20
    )
    updated_scooter = scooter.update(db=db, db_obj=db_scooter, obj_in=scooter_update)
    
    assert updated_scooter.status == scooter_update.status
    assert updated_scooter.battery_level == scooter_update.battery_level
    assert updated_scooter.model == scooter_in.model
    assert updated_scooter.location == scooter_in.location


def test_delete_scooter(db: Session):
    # Create a scooter first
    scooter_in = ScooterCreate(
        model="Xiaomi Pro 2",
        status="available",
        battery_level=85,
        location={"lat": 39.9175, "lng": 116.4076}
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)
    
    # Delete the scooter
    deleted_scooter = scooter.remove(db=db, id=db_scooter.id)
    assert deleted_scooter.id == db_scooter.id
    
    # Verify scooter is deleted
    fetched_scooter = scooter.get(db=db, id=db_scooter.id)
    assert fetched_scooter is None