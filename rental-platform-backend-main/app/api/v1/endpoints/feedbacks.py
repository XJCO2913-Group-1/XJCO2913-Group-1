from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session

from app import crud, models
from app.api.deps import get_db, get_current_user
from app.models.feedback import FeedbackPriority, FeedbackStatus, FeedbackType
from app.schemas.feedback import (
    Feedback,
    FeedbackCreate,
    FeedbackUpdate,
    FeedbackWithDetails,
    FeedbackTypeOption,
    FeedbackTypeOptions,
)

from datetime import datetime

router = APIRouter()


@router.get("/types", response_model=FeedbackTypeOptions)
async def get_feedback_types() -> Any:
    """获取所有反馈类型选项"""
    options = [
        FeedbackTypeOption(
            value=FeedbackType.SCOOTER_DAMAGE.value,
            label="Scooter Damage",
            description="Report physical damage issues with the scooter, such as wheel damage or body cracks.",
            priority_default=FeedbackPriority.HIGH.value,
        ),
        FeedbackTypeOption(
            value=FeedbackType.PAYMENT_ISSUE.value,
            label="Payment Issue",
            description="Report issues encountered during payment, such as duplicate charges or payment failures.",
            priority_default=FeedbackPriority.HIGH.value,
        ),
        FeedbackTypeOption(
            value=FeedbackType.APP_ISSUE.value,
            label="App Issue",
            description="Report issues encountered while using the app, such as interface errors or functionality problems.",
            priority_default=FeedbackPriority.MEDIUM.value,
        ),
        FeedbackTypeOption(
            value=FeedbackType.RENTAL_ISSUE.value,
            label="Rental Issue",
            description="Report issues encountered during rental, such as inability to start or end a rental.",
            priority_default=FeedbackPriority.MEDIUM.value,
        ),
        FeedbackTypeOption(
            value=FeedbackType.OTHER.value,
            label="Other Issues",
            description="Report other issues not listed.",
            priority_default=FeedbackPriority.LOW.value,
        ),
    ]
    return FeedbackTypeOptions(options=options)


@router.post("/", response_model=Feedback, status_code=status.HTTP_201_CREATED)
async def create_feedback(
    feedback_in: FeedbackCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
) -> Any:
    """创建新的反馈"""
    # 根据反馈类型设置默认优先级（如果未提供）
    if feedback_in.priority not in [
        FeedbackPriority.HIGH.value,
        FeedbackPriority.MEDIUM.value,
        FeedbackPriority.LOW.value,
    ]:
        if (
            feedback_in.feedback_type == FeedbackType.SCOOTER_DAMAGE.value
            or feedback_in.feedback_type == FeedbackType.PAYMENT_ISSUE.value
        ):
            feedback_in.priority = FeedbackPriority.HIGH.value
        elif (
            feedback_in.feedback_type == FeedbackType.APP_ISSUE.value
            or feedback_in.feedback_type == FeedbackType.RENTAL_ISSUE.value
        ):
            feedback_in.priority = FeedbackPriority.MEDIUM.value
        else:
            feedback_in.priority = FeedbackPriority.LOW.value

    # 验证关联的滑板车和租赁（如果提供）
    if feedback_in.scooter_id:
        scooter = crud.scooter.get(db=db, id=feedback_in.scooter_id)
        if not scooter:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Scooter not found"
            )

    if feedback_in.rental_id:
        rental = crud.rental.get(db=db, id=feedback_in.rental_id)
        if not rental:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Rental not found"
            )
        # 验证租赁是否属于当前用户
        if rental.user_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not enough permissions to access this rental",
            )

    # 创建反馈
    feedback = crud.feedback.create_with_user(
        db=db, obj_in=feedback_in, user_id=current_user.id
    )
    return feedback


@router.get("/", response_model=List[Feedback])
async def read_feedbacks(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
    skip: int = 0,
    limit: int = 100,
    status: Optional[str] = None,
) -> Any:
    """获取当前用户的所有反馈"""
    feedbacks = crud.feedback.get_by_user(
        db=db, user_id=current_user.id, skip=skip, limit=limit
    )

    # 如果指定了状态，过滤结果
    if status:
        feedbacks = [f for f in feedbacks if f.status == status]

    return feedbacks


@router.get("/{feedback_id}", response_model=Feedback)
async def read_feedback(
    feedback_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
) -> Any:
    """获取特定反馈"""
    feedback = crud.feedback.get_by_id_and_user(
        db=db, id=feedback_id, user_id=current_user.id
    )
    if not feedback:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Feedback not found"
        )
    return feedback


@router.put("/{feedback_id}", response_model=Feedback)
async def update_feedback(
    feedback_id: int,
    feedback_in: FeedbackUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
) -> Any:
    """更新反馈"""
    feedback = crud.feedback.get_by_id_and_user(
        db=db, id=feedback_id, user_id=current_user.id
    )
    if not feedback:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Feedback not found"
        )

    # 用户只能更新反馈类型和详情，不能更新状态和处理信息
    update_data = {
        "feedback_type": feedback_in.feedback_type,
        "feedback_detail": feedback_in.feedback_detail,
    }

    # 过滤掉None值
    update_data = {k: v for k, v in update_data.items() if v is not None}

    feedback = crud.feedback.update(db=db, db_obj=feedback, obj_in=update_data)
    return feedback


# 以下是管理员API


@router.get("/admin/all", response_model=List[FeedbackWithDetails])
async def read_all_feedbacks(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
    skip: int = 0,
    limit: int = 100,
    priority: Optional[str] = None,
    status: Optional[str] = None,
) -> Any:
    """获取所有反馈（管理员）"""
    # TODO: 添加管理员权限检查

    # 获取所有反馈
    feedbacks = crud.feedback.get_multi(db=db, skip=skip, limit=limit)

    # 根据优先级和状态过滤
    if priority:
        feedbacks = [f for f in feedbacks if f.priority == priority]
    if status:
        feedbacks = [f for f in feedbacks if f.status == status]

    # 添加详细信息
    result = []
    for f in feedbacks:
        feedback_with_details = FeedbackWithDetails.from_orm(f)

        # 添加用户名
        if f.user:
            feedback_with_details.user_name = f.user.name

        # 添加滑板车型号
        if f.scooter:
            feedback_with_details.scooter_model = f.scooter.model

        # 添加处理人姓名
        if f.handler:
            feedback_with_details.handler_name = f.handler.name

        result.append(feedback_with_details)

    return result


@router.get("/admin/high-priority", response_model=List[FeedbackWithDetails])
async def read_high_priority_feedbacks(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    """获取所有高优先级反馈（管理员）"""
    # TODO: 添加管理员权限检查

    # 获取高优先级反馈
    feedbacks = crud.feedback.get_high_priority(db=db, skip=skip, limit=limit)

    # 添加详细信息
    result = []
    for f in feedbacks:
        feedback_with_details = FeedbackWithDetails.from_orm(f)

        # 添加用户名
        if f.user:
            feedback_with_details.user_name = f.user.name

        # 添加滑板车型号
        if f.scooter:
            feedback_with_details.scooter_model = f.scooter.model

        # 添加处理人姓名
        if f.handler:
            feedback_with_details.handler_name = f.handler.name

        result.append(feedback_with_details)

    return result


@router.put("/admin/{feedback_id}", response_model=Feedback)
async def admin_update_feedback(
    feedback_id: int,
    feedback_in: FeedbackUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
) -> Any:
    """管理员更新反馈"""
    # TODO: 添加管理员权限检查

    feedback = crud.feedback.get(db=db, id=feedback_id)
    if not feedback:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Feedback not found"
        )

    # 管理员可以更新所有字段
    feedback = crud.feedback.update(db=db, db_obj=feedback, obj_in=feedback_in)

    # 如果更新了状态为已解决，记录解决时间和处理人
    if feedback_in.status == FeedbackStatus.RESOLVED.value:
        update_data = {"resolved_at": datetime.utcnow(), "handled_by": current_user.id}
        feedback = crud.feedback.update(db=db, db_obj=feedback, obj_in=update_data)

    return feedback


@router.post("/admin/{feedback_id}/resolve", response_model=Feedback)
async def resolve_feedback(
    feedback_id: int,
    resolution_notes: str = Query(..., description="解决方案说明"),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
) -> Any:
    """解决反馈（管理员）"""
    # TODO: 添加管理员权限检查

    feedback = crud.feedback.get(db=db, id=feedback_id)
    if not feedback:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Feedback not found"
        )

    # 更新状态为已解决，并添加解决方案说明
    feedback = crud.feedback.update_status(
        db=db,
        db_obj=feedback,
        status=FeedbackStatus.RESOLVED.value,
        handler_id=current_user.id,
    )

    feedback = crud.feedback.add_resolution_notes(
        db=db, db_obj=feedback, notes=resolution_notes, handler_id=current_user.id
    )

    return feedback
