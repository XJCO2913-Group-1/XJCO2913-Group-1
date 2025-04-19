from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api import deps
from app.crud.scooter import scooter
from app.schemas.scooter import Scooter, ScooterCreate, ScooterUpdate

router = APIRouter()


@router.get("/", response_model=List[Scooter])
async def read_scooters(db: Session = Depends(deps.get_db)) -> Any:
    """
    Retrieve scooters.
    """
    return scooter.get_multi(db=db)


@router.post("/", response_model=Scooter, status_code=status.HTTP_201_CREATED)
async def create_scooter(
    scooter_in: ScooterCreate, db: Session = Depends(deps.get_db)
) -> Any:
    """
    Create new scooter.
    """
    return scooter.create(db=db, obj_in=scooter_in)


@router.get("/{scooter_id}", response_model=Scooter)
async def read_scooter(scooter_id: int, db: Session = Depends(deps.get_db)) -> Any:
    """
    Get a specific scooter by id.
    """
    scooter_obj = scooter.get(db=db, id=scooter_id)
    if not scooter_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Scooter not found"
        )
    return scooter_obj


@router.put("/{scooter_id}", response_model=Scooter)
async def update_scooter(
    scooter_id: int, scooter_in: ScooterUpdate, db: Session = Depends(deps.get_db)
) -> Any:
    """
    Update a scooter.
    """
    scooter_obj = scooter.get(db=db, id=scooter_id)
    if not scooter_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Scooter not found"
        )
    return scooter.update(db=db, db_obj=scooter_obj, obj_in=scooter_in)


@router.delete("/{scooter_id}", response_model=Scooter)
async def delete_scooter(scooter_id: int, db: Session = Depends(deps.get_db)) -> Any:
    """
    Delete a scooter.
    """
    scooter_obj = scooter.get(db=db, id=scooter_id)
    if not scooter_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Scooter not found"
        )
    return scooter.remove(db=db, id=scooter_id)
