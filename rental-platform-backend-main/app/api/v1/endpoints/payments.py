from typing import Any, List
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session

from app import crud, models, schemas
from app.api import deps
from app.core.payment import process_payment
from app.core.email import send_payment_confirmation
from app.models.payment import PaymentStatus, PaymentMethod
from app.models.rental import RentalStatus

router = APIRouter()


@router.get("/", response_model=List[schemas.Payment])
async def read_payments(
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_user),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """
    获取当前用户的所有支付记录
    """
    payments = crud.payment.get_by_user(
        db=db, user_id=current_user.id, skip=skip, limit=limit
    )
    return payments


@router.post("/process", response_model=schemas.PaymentConfirmation)
async def process_payment_endpoint(
    *,
    db: Session = Depends(deps.get_db),
    payment_in: schemas.PaymentCreate,
    current_user: models.User = Depends(deps.get_current_user),
    background_tasks: BackgroundTasks,
) -> Any:
    """
    处理支付
    """
    # 检查租赁是否存在
    rental = crud.rental.get(db=db, id=payment_in.rental_id)
    if not rental:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Rental not found"
        )

    # 检查租赁是否属于当前用户
    if rental.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to access this rental",
        )

    # 检查支付金额是否与租赁费用一致
    if payment_in.amount != rental.cost:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Payment amount {payment_in.amount} does not match rental cost {rental.cost}",
        )

    # 根据支付方式处理
    card_data = None
    saved_card_id = None

    if payment_in.payment_method == PaymentMethod.CARD:
        # # 使用新卡支付
        # if not payment_in.card_details:
        #     raise HTTPException(
        #         status_code=status.HTTP_400_BAD_REQUEST,
        #         detail="Card details required for card payment"
        #     )

        # # 验证卡信息
        # card_valid, error_message = validate_card(
        #     payment_in.card_details.get("card_number", ""),
        #     payment_in.card_details.get("card_expiry_month", ""),
        #     payment_in.card_details.get("card_expiry_year", ""),
        #     payment_in.card_details.get("cvv", "")
        # )

        # if not card_valid:
        #     raise HTTPException(
        #         status_code=status.HTTP_400_BAD_REQUEST,
        #         detail=error_message
        #     )

        card_data = payment_in.card_details

        # 如果用户选择保存卡信息
        if payment_in.card_details.get("save_for_future", False):
            # 创建新的支付卡记录
            card_create = schemas.PaymentCardCreate(
                card_holder_name=payment_in.card_details.get("card_holder_name", ""),
                card_number=payment_in.card_details.get("card_number", ""),
                card_expiry_month=payment_in.card_details.get("card_expiry_month", ""),
                card_expiry_year=payment_in.card_details.get("card_expiry_year", ""),
                cvv=payment_in.card_details.get("cvv", ""),
                is_default=payment_in.card_details.get("set_as_default", False),
            )

            # 保存卡信息
            saved_card = crud.payment_card.create_with_user(
                db=db, obj_in=card_create, user_id=current_user.id
            )
            saved_card_id = saved_card.id

    elif payment_in.payment_method == PaymentMethod.SAVED_CARD:
        # 使用已保存的卡支付
        if not payment_in.payment_card_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Payment card ID required for saved card payment",
            )

        # 检查卡是否存在且属于当前用户
        card = crud.payment_card.get_by_id_and_user(
            db=db, id=payment_in.payment_card_id, user_id=current_user.id
        )
        if not card:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Payment card not found"
            )

        saved_card_id = card.id

    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid payment method"
        )

    # 创建支付记录
    payment = crud.payment.create_with_user_and_rental(
        db=db,
        obj_in=schemas.PaymentCreate(
            rental_id=payment_in.rental_id,
            amount=payment_in.amount,
            currency=payment_in.currency or "CNY",
            payment_method=payment_in.payment_method,
            payment_card_id=saved_card_id,
            status=PaymentStatus.PENDING,
        ),
        user_id=current_user.id,
    )

    # 模拟支付处理
    payment_result = process_payment(
        amount=payment_in.amount, card_data=card_data, saved_card_id=saved_card_id
    )

    # 更新支付状态
    payment = crud.payment.update_payment_status(
        db=db,
        db_obj=payment,
        status=payment_result["status"],
        transaction_id=payment_result.get("transaction_id"),
    )

    # 如果支付成功，更新租赁状态
    if payment_result["success"]:
        # 在实际应用中，可能需要更新租赁状态为已支付
        crud.rental.update_rental_status(db=db, rental=rental, status=RentalStatus.PAID)

        crud.scooter.update_scooter_status(
            db=db, scooter_id=rental.scooter_id, status="available"
        )

        # 发送支付确认邮件
        payment_info = {
            "id": payment.id,
            "rental_id": payment.rental_id,
            "amount": payment.amount,
            "currency": payment.currency,
            "status": payment.status,
            "payment_date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "transaction_id": payment.transaction_id,
        }

        background_tasks.add_task(
            send_payment_confirmation,
            email_to=current_user.email,
            payment_info=payment_info,
        )

    # 返回支付确认信息
    return schemas.PaymentConfirmation(
        payment_id=payment.id,
        status=payment.status,
        transaction_id=payment.transaction_id,
        message=payment_result.get("message", ""),
        rental_id=payment.rental_id,
        amount=payment.amount,
        currency=payment.currency,
        payment_method=payment.payment_method,
        payment_date=payment.created_at,
    )


@router.get("/{payment_id}", response_model=schemas.Payment)
async def read_payment(
    *,
    db: Session = Depends(deps.get_db),
    payment_id: int,
    current_user: models.User = Depends(deps.get_current_user),
) -> Any:
    """
    获取特定支付记录
    """
    payment = crud.payment.get_by_id_and_user(
        db=db, id=payment_id, user_id=current_user.id
    )
    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Payment not found"
        )
    return payment
