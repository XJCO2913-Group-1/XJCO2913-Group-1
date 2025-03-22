import pytest

from datetime import datetime

from sqlalchemy.orm import Session

from fastapi import HTTPException


from app.crud.rental import rental

from app.schemas.rental import RentalCreate, RentalUpdate

from app.models.rental import Rental

from app.models.scooter import Scooter



def test_create_rental(db: Session):

    # 创建一个滑板车

    scooter = Scooter(

        model="Test Model",

        status="available",

        location={"lat": 39.9891, "lng": 116.3176}
    )
    db.add(scooter)

    db.commit()

    db.refresh(scooter)


    # 创建租赁记录

    rental_in = RentalCreate(
        scooter_id=scooter.id,

        user_id=1,


        rental_period="1hr",

        status="active"
    )

    db_rental = rental.create_with_scooter(db=db, rental_in=rental_in, user_id=1, cost=10.0, start_time=datetime.now())
    
    assert db_rental.scooter_id == rental_in.scooter_id
    assert db_rental.user_id == rental_in.user_id
    assert db_rental.status == rental_in.status
    assert db_rental.cost == 10.0
    

    # 验证滑板车状态是否更新

    updated_scooter = db.query(Scooter).filter(Scooter.id == scooter.id).first()

    assert updated_scooter.status == "in_use"



def test_get_user_rentals(db: Session):

    # 创建测试数据

    scooter = Scooter(

        model="Test Model",

        status="available",

        location={"lat": 39.9087, "lng": 116.3914}
    )
    db.add(scooter)

    db.commit()

    db.refresh(scooter)


    rental_in = RentalCreate(
        scooter_id=scooter.id,

        user_id=1,

        rental_period="1hr",

        status="active"
    )

    rental.create_with_scooter(db=db, rental_in=rental_in, user_id=1, cost=10.0, start_time=datetime.now())
    

    rentals = rental.get_user_rentals(db=db, user_id=1)

    assert len(rentals) == 1

    assert all(isinstance(r, Rental) for r in rentals)

    assert all(r.user_id == 1 for r in rentals)



def test_get_active_rentals(db: Session):

    # 创建测试数据

    scooter = Scooter(

        model="Test Model",

        status="available",

        location={"lat": 39.9175, "lng": 116.4076}
    )
    db.add(scooter)

    db.commit()

    db.refresh(scooter)


    rental_in = RentalCreate(
        scooter_id=scooter.id,

        user_id=1,

        rental_period="1hr",

        status="active"
    )

    rental.create_with_scooter(db=db, rental_in=rental_in, user_id=1, cost=10.0, start_time=datetime.now())
    

    active_rentals = rental.get_active_rentals(db=db)

    assert len(active_rentals) > 0

    assert all(r.status == "active" for r in active_rentals)



def test_get_rental_by_id(db: Session):

    # 创建测试数据

    scooter = Scooter(

        model="Test Model",

        status="available",

        location={"lat": 39.9219, "lng": 116.4402}
    )
    db.add(scooter)

    db.commit()

    db.refresh(scooter)


    rental_in = RentalCreate(
        scooter_id=scooter.id,

        user_id=1,

        rental_period="1hr",

        status="active"
    )

    created_rental = rental.create_with_scooter(db=db, rental_in=rental_in, user_id=1, cost=10.0, start_time=datetime.now())
    

    fetched_rental = rental.get_by_id(db=db, rental_id=created_rental.id)

    assert fetched_rental

    assert fetched_rental.id == created_rental.id

    assert fetched_rental.scooter_id == rental_in.scooter_id

    assert fetched_rental.user_id == rental_in.user_id



def test_update_rental(db: Session):

    # 创建测试数据

    scooter = Scooter(

        model="Test Model",

        status="available",

        location={"lat": 39.9175, "lng": 116.4076}
    )
    db.add(scooter)

    db.commit()

    db.refresh(scooter)


    rental_in = RentalCreate(
        scooter_id=scooter.id,

        user_id=1,

        rental_period="1hr",

        status="active"
    )

    db_rental = rental.create_with_scooter(db=db, rental_in=rental_in, user_id=1, cost=10.0, start_time=datetime.now())
    

    # 更新租赁记录

    rental_update = RentalUpdate(status="completed")

    updated_rental = rental.update_rental(db=db, rental=db_rental, rental_in=rental_update)
    

    assert updated_rental.status == rental_update.status

    assert updated_rental.scooter_id == rental_in.scooter_id

    assert updated_rental.user_id == rental_in.user_id



def test_delete_rental(db: Session):

    # 创建测试数据

    scooter = Scooter(

        model="Test Model",

        status="available",

        location={"lat": 39.9175, "lng": 116.4076}
    )
    db.add(scooter)

    db.commit()

    db.refresh(scooter)


    rental_in = RentalCreate(
        scooter_id=scooter.id,

        user_id=1,

        rental_period="1hr",

        status="active"
    )

    created_rental = rental.create_with_scooter(db=db, rental_in=rental_in, user_id=1, cost=10.0, start_time=datetime.now())
    

    # 删除租赁记录
    deleted_rental = rental.delete_rental(db=db, rental_id=created_rental.id)
    assert deleted_rental
    assert deleted_rental.id == created_rental.id
    

    # 确认记录已被删除

    fetched_rental = rental.get_by_id(db=db, rental_id=created_rental.id)

    assert fetched_rental is None