from sqlalchemy.orm import Session

from app.crud.scooter import scooter
from app.schemas.scooter import ScooterCreate, ScooterUpdate
from app.models.scooter import Scooter


def test_create_scooter(db: Session):
    scooter_in = ScooterCreate(
        model="Xiaomi M365",
        status="available",
        battery_level=100,
        location={"lat": 39.9891, "lng": 116.3176},
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
        location={"lat": 39.9087, "lng": 116.3914},
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
            location={"lat": 39.9891, "lng": 116.3176},
        ),
        ScooterCreate(
            model="Ninebot Max",
            status="maintenance",
            battery_level=50,
            location={"lat": 39.9219, "lng": 116.4402},
        ),
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
        location={"lat": 39.9175, "lng": 116.4076},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)

    # Update the scooter
    scooter_update = ScooterUpdate(status="maintenance", battery_level=20)
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
        location={"lat": 39.9175, "lng": 116.4076},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)

    # Delete the scooter
    deleted_scooter = scooter.remove(db=db, id=db_scooter.id)
    assert deleted_scooter.id == db_scooter.id

    # Verify scooter is deleted
    fetched_scooter = scooter.get(db=db, id=db_scooter.id)
    assert fetched_scooter is None


def test_create_scooter_with_low_battery(db: Session):
    scooter_in = ScooterCreate(
        model="Ninebot ES4",
        status="maintenance",
        battery_level=5,
        location={"lat": 40.0123, "lng": 116.4567},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)
    assert db_scooter.model == scooter_in.model
    assert db_scooter.status == scooter_in.status
    assert db_scooter.battery_level == scooter_in.battery_level
    assert db_scooter.location == scooter_in.location


def test_create_scooter_with_full_battery(db: Session):
    scooter_in = ScooterCreate(
        model="Segway Ninebot Max",
        status="available",
        battery_level=100,
        location={"lat": 39.9123, "lng": 116.3887},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)
    assert db_scooter.model == scooter_in.model
    assert db_scooter.status == scooter_in.status
    assert db_scooter.battery_level == scooter_in.battery_level
    assert db_scooter.location == scooter_in.location


def test_create_different_scooter_model(db: Session):
    scooter_in = ScooterCreate(
        model="Razor E Prime",
        status="available",
        battery_level=92,
        location={"lat": 39.9567, "lng": 116.4321},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)
    assert db_scooter.model == scooter_in.model
    assert db_scooter.status == scooter_in.status
    assert db_scooter.battery_level == scooter_in.battery_level
    assert db_scooter.location == scooter_in.location


def test_get_scooter_different_model(db: Session):
    scooter_in = ScooterCreate(
        model="GoTrax GXL V2",
        status="available",
        battery_level=87,
        location={"lat": 39.9234, "lng": 116.4111},
    )
    created_scooter = scooter.create(db=db, obj_in=scooter_in)

    fetched_scooter = scooter.get(db=db, id=created_scooter.id)
    assert fetched_scooter
    assert fetched_scooter.model == scooter_in.model
    assert fetched_scooter.status == scooter_in.status
    assert fetched_scooter.battery_level == scooter_in.battery_level
    assert fetched_scooter.location == scooter_in.location


def test_get_scooter_invalid_id(db: Session):
    fetched_scooter = scooter.get(db=db, id=99999)
    assert fetched_scooter is None


def test_update_scooter_battery_only(db: Session):
    scooter_in = ScooterCreate(
        model="Dualtron Mini",
        status="available",
        battery_level=90,
        location={"lat": 39.9876, "lng": 116.3456},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)

    # Update only battery
    scooter_update = ScooterUpdate(battery_level=65)
    updated_scooter = scooter.update(db=db, db_obj=db_scooter, obj_in=scooter_update)

    assert updated_scooter.battery_level == scooter_update.battery_level
    assert updated_scooter.status == scooter_in.status
    assert updated_scooter.model == scooter_in.model
    assert updated_scooter.location == scooter_in.location


def test_update_scooter_all_fields(db: Session):
    scooter_in = ScooterCreate(
        model="Zero 9",
        status="available",
        battery_level=92,
        location={"lat": 39.9234, "lng": 116.4321},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)

    # Update all fields
    new_location = {"lat": 39.8765, "lng": 116.5678}
    scooter_update = ScooterUpdate(
        model="Zero 10",
        status="maintenance",
        battery_level=30,
        location=new_location
    )
    updated_scooter = scooter.update(db=db, db_obj=db_scooter, obj_in=scooter_update)

    assert updated_scooter.model == scooter_update.model
    assert updated_scooter.status == scooter_update.status
    assert updated_scooter.battery_level == scooter_update.battery_level
    assert updated_scooter.location == scooter_update.location


def test_delete_scooter_and_verify(db: Session):
    scooter_in = ScooterCreate(
        model="Fluid Horizon",
        status="available",
        battery_level=95,
        location={"lat": 39.9876, "lng": 116.5432},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)

    # Delete the scooter
    deleted_scooter = scooter.remove(db=db, id=db_scooter.id)
    assert deleted_scooter.id == db_scooter.id
    assert deleted_scooter.model == scooter_in.model

    # Verify scooter is deleted
    fetched_scooter = scooter.get(db=db, id=db_scooter.id)
    assert fetched_scooter is None


def test_create_scooter_with_zero_battery(db: Session):
    scooter_in = ScooterCreate(
        model="Xiaomi Essential",
        status="maintenance",
        battery_level=0,
        location={"lat": 39.9234, "lng": 116.4111},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)
    assert db_scooter.model == scooter_in.model
    assert db_scooter.status == scooter_in.status
    assert db_scooter.battery_level == scooter_in.battery_level
    assert db_scooter.location == scooter_in.location


def test_create_and_update_to_zero_battery(db: Session):
    scooter_in = ScooterCreate(
        model="Joyor F3",
        status="available",
        battery_level=50,
        location={"lat": 39.9555, "lng": 116.3456},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)

    # Update to zero battery
    scooter_update = ScooterUpdate(battery_level=0)
    updated_scooter = scooter.update(db=db, db_obj=db_scooter, obj_in=scooter_update)

    assert updated_scooter.battery_level == 0
    assert updated_scooter.status == scooter_in.status


def test_create_and_update_to_full_battery(db: Session):
    scooter_in = ScooterCreate(
        model="FLJ K3",
        status="maintenance",
        battery_level=20,
        location={"lat": 39.9888, "lng": 116.4567},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)

    # Update to full battery and available status
    scooter_update = ScooterUpdate(battery_level=100, status="available")
    updated_scooter = scooter.update(db=db, db_obj=db_scooter, obj_in=scooter_update)

    assert updated_scooter.battery_level == 100
    assert updated_scooter.status == "available"


def test_create_scooter_and_verify_id(db: Session):
    scooter_in = ScooterCreate(
        model="Speedway Mini 4 Pro",
        status="available",
        battery_level=85,
        location={"lat": 39.9111, "lng": 116.3987},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)
    
    # Verify ID is assigned and can be fetched
    assert db_scooter.id is not None
    fetched_scooter = scooter.get(db=db, id=db_scooter.id)
    assert fetched_scooter is not None
    assert fetched_scooter.id == db_scooter.id


def test_create_scooter_and_delete_twice(db: Session):
    scooter_in = ScooterCreate(
        model="EMOVE Cruiser",
        status="available",
        battery_level=90,
        location={"lat": 39.9222, "lng": 116.4333},
    )
    db_scooter = scooter.create(db=db, obj_in=scooter_in)
    
    # First delete
    deleted_scooter = scooter.remove(db=db, id=db_scooter.id)
    assert deleted_scooter.id == db_scooter.id
    
    # Second delete attempt should return None
    deleted_again = scooter.get(db=db, id=db_scooter.id)
    assert deleted_again is None