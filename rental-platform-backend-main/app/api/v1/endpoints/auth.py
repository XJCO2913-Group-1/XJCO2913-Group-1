from datetime import timedelta
from typing import Any

from fastapi import (
    APIRouter,
    Depends,
    Form,
    HTTPException,
    Request,
    status,
    BackgroundTasks,
)
from fastapi.responses import HTMLResponse
from fastapi.security import OAuth2PasswordRequestForm
from jinja2 import Template

from app.core.security import create_access_token, verify_password
from app.core.config import settings
from app.schemas.token import Token, TokenPayload
from app.api.deps import get_db
from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.password import PasswordResetRequest
from app.core.email import send_password_reset_email
from app.crud.user import user
from jose import jwt, JWTError
from pydantic import ValidationError
from app.core.email import password_reset_form_template

router = APIRouter()


@router.post("/login", response_model=Token)
async def login_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)
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
            status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user"
        )

    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
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
    db: Session = Depends(get_db),
) -> Any:
    """
    Request a password reset email
    """
    user_obj = user.get_by_email(db, email=reset_request.email)
    if not user_obj:
        # 即使用户不存在，也返回成功，以防止用户枚举
        return {
            "message": "If the email exists, we have sent a password reset email..."
        }

    # 创建密码重置令牌
    password_reset_token_expires = timedelta(hours=24)
    password_reset_token = create_access_token(
        subject=str(user_obj.id), expires_delta=password_reset_token_expires
    )

    # 在后台发送密码重置邮件
    background_tasks.add_task(
        send_password_reset_email, email_to=user_obj.email, token=password_reset_token
    )

    return {"message": "If the email exists, we have sent a password reset email..."}


@router.get("/reset-password-form", response_class=HTMLResponse)
async def reset_password_form(
    token: str,
    request: Request,
) -> Any:
    """
    Serve HTML form for password reset
    """
    # Create full URL for form submission
    submit_url = f"{request.url.scheme}://{request.url.netloc}{settings.API_V1_STR}/auth/reset-password"

    # Render the HTML form template
    template = Template(password_reset_form_template)
    html_content = template.render(
        token=token, submit_url=submit_url, project_name=settings.PROJECT_NAME
    )

    return HTMLResponse(content=html_content)


@router.post("/reset-password", response_class=HTMLResponse)
async def reset_password(
    token: str = Form(...),
    password: str = Form(...),
    confirm_password: str = Form(...),
    db: Session = Depends(get_db),
) -> Any:
    """
    Reset password using reset token from form submission
    """
    # Validate that passwords match
    if password != confirm_password:
        return HTMLResponse(
            content="<h1>Error</h1><p>Passwords do not match!</p><p><a href='javascript:history.back()'>Go back</a></p>",
            status_code=400,
        )

    try:
        # Verify token
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        token_data = TokenPayload(**payload)

        if not token_data.sub:
            return HTMLResponse(
                content="<h1>Error</h1><p>Invalid or expired token</p>", status_code=400
            )

        # Get user
        user_obj = user.get(db, id=int(token_data.sub))
        if not user_obj:
            return HTMLResponse(
                content="<h1>Error</h1><p>User not found</p>", status_code=404
            )

        # Update password
        user.update(db, db_obj=user_obj, obj_in={"password": password})

        # Return success page
        success_html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>Password Reset Successful</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    max-width: 500px;
                    margin: 0 auto;
                    padding: 20px;
                    text-align: center;
                }
                .container {
                    border: 1px solid #ddd;
                    border-radius: 5px;
                    padding: 20px;
                    margin-top: 30px;
                    box-shadow: 0 0 10px rgba(0,0,0,0.1);
                }
                h1 {
                    color: #4CAF50;
                }
                .btn {
                    display: inline-block;
                    background-color: #4CAF50;
                    color: white;
                    padding: 10px 20px;
                    text-decoration: none;
                    border-radius: 4px;
                    margin-top: 20px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Password Reset Successful!</h1>
                <p>Your password has been successfully reset.</p>
                <p>You can now log in with your new password.</p>
                <a href="#" class="btn" onclick="window.close()">Close</a>
            </div>
        </body>
        </html>
        """
        return HTMLResponse(content=success_html)

    except (JWTError, ValidationError):
        return HTMLResponse(
            content="<h1>Error</h1><p>Invalid or expired token</p>", status_code=400
        )
