from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps

router = APIRouter()


@router.get("/", response_model=List[schemas.PaymentCard])
async def read_payment_cards(
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_user),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """
    获取当前用户的所有支付卡
    """
    cards = crud.payment_card.get_by_user(
        db=db, user_id=current_user.id, skip=skip, limit=limit
    )
    return cards


@router.post("/", response_model=schemas.PaymentCard, status_code=status.HTTP_201_CREATED)
async def create_payment_card(
    *,
    db: Session = Depends(deps.get_db),
    card_in: schemas.PaymentCardCreate,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    创建新的支付卡
    """
    # 如果是第一张卡或者明确设置为默认卡，则设置为默认
    existing_cards = crud.payment_card.get_by_user(db=db, user_id=current_user.id)
    if not existing_cards or card_in.is_default:
        card_in.is_default = True
    
    card = crud.payment_card.create_with_user(
        db=db, obj_in=card_in, user_id=current_user.id
    )
    return card


@router.get("/default", response_model=schemas.PaymentCard)
async def read_default_payment_card(
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    获取当前用户的默认支付卡
    """
    card = crud.payment_card.get_default_card(db=db, user_id=current_user.id)
    if not card:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Default payment card not found"
        )
    return card


@router.get("/{card_id}", response_model=schemas.PaymentCard)
async def read_payment_card(
    *,
    db: Session = Depends(deps.get_db),
    card_id: int,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    获取特定支付卡
    """
    card = crud.payment_card.get_by_id_and_user(
        db=db, id=card_id, user_id=current_user.id
    )
    if not card:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment card not found"
        )
    return card


@router.put("/{card_id}", response_model=schemas.PaymentCard)
async def update_payment_card(
    *,
    db: Session = Depends(deps.get_db),
    card_id: int,
    card_in: schemas.PaymentCardUpdate,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    更新支付卡
    """
    card = crud.payment_card.get_by_id_and_user(
        db=db, id=card_id, user_id=current_user.id
    )
    if not card:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment card not found"
        )
    
    card = crud.payment_card.update_card(db=db, db_obj=card, obj_in=card_in)
    return card


@router.delete("/{card_id}", response_model=schemas.PaymentCard)
async def delete_payment_card(
    *,
    db: Session = Depends(deps.get_db),
    card_id: int,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    删除支付卡
    """
    card = crud.payment_card.delete_by_id_and_user(
        db=db, id=card_id, user_id=current_user.id
    )
    if not card:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment card not found"
        )
    return card