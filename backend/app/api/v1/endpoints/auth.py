from datetime import timedelta
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from fastapi.security import OAuth2PasswordRequestForm

from app.core.security import create_access_token, verify_password
from app.core.config import settings
from app.schemas.token import Token, TokenPayload
from app.api.deps import get_db
from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.password import PasswordResetRequest, PasswordReset
from app.core.email import send_password_reset_email
from app.crud.user import user
from jose import jwt, JWTError
from pydantic import ValidationError

router = APIRouter()


@router.post("/login", response_model=Token)
async def login_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
) -> Any:
    """
    OAuth2 compatible token login, get an access token for future requests
    """
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )

    access_token_expires = timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return {
        "access_token": create_access_token(
            subject=str(user.id), expires_delta=access_token_expires
        ),
        "token_type": "bearer",
    }


@router.post("/test-token", response_model=dict)
async def test_token() -> Any:
    """
    Test access token
    """
    return {"msg": "Token is valid"}


@router.post("/password-reset-request", status_code=status.HTTP_202_ACCEPTED)
async def request_password_reset(
    reset_request: PasswordResetRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
) -> Any:
    """
    Request a password reset email
    """
    user_obj = user.get_by_email(db, email=reset_request.email)
    if not user_obj:
        # 即使用户不存在，也返回成功，以防止用户枚举
        return {"message": "如果该邮箱存在，我们已发送密码重置邮件"}
    
    # 创建密码重置令牌
    password_reset_token_expires = timedelta(hours=24)
    password_reset_token = create_access_token(
        subject=str(user_obj.id),
        expires_delta=password_reset_token_expires
    )
    
    # 在后台发送密码重置邮件
    background_tasks.add_task(
        send_password_reset_email,
        email_to=user_obj.email,
        token=password_reset_token
    )
    
    return {"message": "如果该邮箱存在，我们已发送密码重置邮件"}


@router.post("/reset-password", status_code=status.HTTP_200_OK)
async def reset_password(
    password_reset: PasswordReset,
    db: Session = Depends(get_db)
) -> Any:
    """
    Reset password using reset token
    """
    try:
        # 验证令牌
        payload = jwt.decode(
            password_reset.token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        token_data = TokenPayload(**payload)
        
        if not token_data.sub:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid token"
            )
            
        # 获取用户
        user_obj = user.get(db, id=int(token_data.sub))
        if not user_obj:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
            
        # 更新密码
        user.update(db, db_obj=user_obj, obj_in={"password": password_reset.password})
        
        return {"message": "密码已成功重置"}
        
    except (JWTError, ValidationError):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid token"
        )
