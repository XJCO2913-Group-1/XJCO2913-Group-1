from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps

router = APIRouter()


@router.post("/", response_model=schemas.ScooterPrice)
def create_scooter_price(
    *,
    db: Session = Depends(deps.get_db),
    scooter_price_in: schemas.ScooterPriceCreate,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Create new scooter price. (Superuser only)
    """
    existing_price = crud.scooter_price.get_by_model(db, model=scooter_price_in.model)
    if existing_price:
        raise HTTPException(
            status_code=400,
            detail=f"A price for scooter model '{scooter_price_in.model}' already exists.",
        )
    scooter_price = crud.scooter_price.create(db=db, obj_in=scooter_price_in)
    return scooter_price


@router.get("/", response_model=List[schemas.ScooterPrice])
def read_scooter_prices(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Retrieve scooter prices.
    """
    scooter_prices = crud.scooter_price.get_multi(db, skip=skip, limit=limit)
    return scooter_prices


@router.get("/{model}", response_model=schemas.ScooterPrice)
def read_scooter_price_by_model(
    *,
    db: Session = Depends(deps.get_db),
    model: str,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Get scooter price by model.
    """
    scooter_price = crud.scooter_price.get_by_model(db, model=model)
    if not scooter_price:
        raise HTTPException(
            status_code=404, detail="Scooter price not found for this model"
        )
    return scooter_price


@router.put("/{id}", response_model=schemas.ScooterPrice)
def update_scooter_price(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    scooter_price_in: schemas.ScooterPriceUpdate,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Update a scooter price. (Superuser only)
    """
    scooter_price = crud.scooter_price.get(db=db, id=id)
    if not scooter_price:
        raise HTTPException(status_code=404, detail="Scooter price not found")
    # Check if updating model to one that already exists
    if scooter_price_in.model and scooter_price_in.model != scooter_price.model:
        existing_price = crud.scooter_price.get_by_model(
            db, model=scooter_price_in.model
        )
        if existing_price and existing_price.id != id:
            raise HTTPException(
                status_code=400,
                detail=f"A price for scooter model '{scooter_price_in.model}' already exists.",
            )
    scooter_price = crud.scooter_price.update(
        db=db, db_obj=scooter_price, obj_in=scooter_price_in
    )
    return scooter_price


@router.delete("/{id}", response_model=schemas.ScooterPrice)
def delete_scooter_price(
    *,
    db: Session = Depends(deps.get_db),
    id: int,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    Delete a scooter price. (Superuser only)
    """
    scooter_price = crud.scooter_price.get(db=db, id=id)
    if not scooter_price:
        raise HTTPException(status_code=404, detail="Scooter price not found")
    scooter_price = crud.scooter_price.remove(db=db, id=id)
    return scooter_price
