from typing import List, Optional
from datetime import datetime
from sqlalchemy.orm import Session
from fastapi.encoders import jsonable_encoder

from app.crud.base import CRUDBase
from app.models.feedback import Feedback, FeedbackStatus, FeedbackPriority
from app.schemas.feedback import FeedbackCreate, FeedbackUpdate


class CRUDFeedback(CRUDBase[Feedback, FeedbackCreate, FeedbackUpdate]):
    def create_with_user(
        self, db: Session, *, obj_in: FeedbackCreate, user_id: int
    ) -> Feedback:
        """创建用户反馈"""
        obj_in_data = jsonable_encoder(obj_in)
        db_obj = Feedback(**obj_in_data, user_id=user_id)

        # 如果反馈优先级为高，自动标记为紧急事项
        if db_obj.priority == FeedbackPriority.HIGH.value:
            db_obj.status = FeedbackStatus.IN_PROGRESS.value

        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_by_user(
        self, db: Session, *, user_id: int, skip: int = 0, limit: int = 100
    ) -> List[Feedback]:
        """获取用户的所有反馈"""
        return (
            db.query(self.model)
            .filter(Feedback.user_id == user_id)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_by_id_and_user(
        self, db: Session, *, id: int, user_id: int
    ) -> Optional[Feedback]:
        """通过ID和用户ID获取反馈"""
        return (
            db.query(self.model)
            .filter(Feedback.id == id, Feedback.user_id == user_id)
            .first()
        )

    def get_high_priority(
        self, db: Session, *, skip: int = 0, limit: int = 100
    ) -> List[Feedback]:
        """获取所有高优先级的反馈"""
        return (
            db.query(self.model)
            .filter(Feedback.priority == FeedbackPriority.HIGH.value)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_by_status(
        self, db: Session, *, status: str, skip: int = 0, limit: int = 100
    ) -> List[Feedback]:
        """通过状态获取反馈"""
        return (
            db.query(self.model)
            .filter(Feedback.status == status)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def update_status(
        self,
        db: Session,
        *,
        db_obj: Feedback,
        status: str,
        handler_id: Optional[int] = None,
    ) -> Feedback:
        """更新反馈状态"""
        update_data = {"status": status}

        if status == FeedbackStatus.RESOLVED.value:
            update_data["resolved_at"] = datetime.utcnow()

        if handler_id:
            update_data["handled_by"] = handler_id

        return super().update(db, db_obj=db_obj, obj_in=update_data)

    def add_resolution_notes(
        self, db: Session, *, db_obj: Feedback, notes: str, handler_id: int
    ) -> Feedback:
        """添加解决方案说明"""
        update_data = {
            "resolution_notes": notes,
            "handled_by": handler_id,
            "updated_at": datetime.utcnow(),
        }
        return super().update(db, db_obj=db_obj, obj_in=update_data)


feedback = CRUDFeedback(Feedback)
