from typing import Any, Dict, Optional
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
from pydantic import EmailStr
from jinja2 import Template

from app.core.config import settings
from app.core.security import create_access_token

conf = ConnectionConfig(
    MAIL_USERNAME=settings.SMTP_USER,
    MAIL_PASSWORD=settings.SMTP_PASSWORD,
    MAIL_FROM=settings.SMTP_FROM_EMAIL,
    MAIL_PORT=settings.SMTP_PORT,
    MAIL_SERVER=settings.SMTP_HOST,
    MAIL_FROM_NAME=settings.PROJECT_NAME,
    MAIL_STARTTLS=True,
    MAIL_SSL_TLS=False,
    USE_CREDENTIALS=True
)

fastmail = FastMail(conf)

rental_confirmation_template = """
<p>尊敬的用户：</p>
<p>您的电动滑板车租赁订单已确认，详情如下：</p>
<ul>
    <li>订单编号：{{ rental_id }}</li>
    <li>滑板车编号：{{ scooter_id }}</li>
    <li>租赁开始时间：{{ start_time }}</li>
    <li>租赁结束时间：{{ end_time }}</li>
    <li>租赁费用：¥{{ total_cost }}</li>
</ul>
<p>祝您使用愉快！</p>
<p>{{ project_name }}团队</p>
"""

password_reset_template = """
<p>尊敬的用户：</p>
<p>您最近请求重置您的密码。请点击下面的链接来重置您的密码：</p>
<p><a href="{{ reset_url }}">重置密码</a></p>
<p>如果您没有请求重置密码，请忽略此邮件。</p>
<p>此链接将在{{ expire_hours }}小时后过期。</p>
<p>{{ project_name }}团队</p>
"""

payment_confirmation_template = """
<p>尊敬的用户：</p>
<p>您的支付已成功处理，详情如下：</p>
<ul>
    <li>支付编号：{{ payment_id }}</li>
    <li>订单编号：{{ rental_id }}</li>
    <li>支付金额：{{ currency }} {{ amount }}</li>
    <li>支付时间：{{ payment_date }}</li>
    <li>交易编号：{{ transaction_id }}</li>
</ul>
<p>感谢您的使用！</p>
<p>{{ project_name }}团队</p>
"""

async def send_rental_confirmation(
    email_to: EmailStr,
    rental_info: Dict[str, Any]
) -> None:
    """发送租赁确认邮件"""
    template = Template(rental_confirmation_template)
    html_content = template.render(
        rental_id=rental_info["id"],
        scooter_id=rental_info["scooter_id"],
        start_time=rental_info["start_time"],
        end_time=rental_info["end_time"],
        total_cost=rental_info["total_cost"],
        project_name=settings.PROJECT_NAME
    )
    
    message = MessageSchema(
        subject=f"{settings.PROJECT_NAME} - 租赁确认",
        recipients=[email_to],
        body=html_content,
        subtype="html"
    )
    
    await fastmail.send_message(message)


async def send_password_reset_email(
    email_to: EmailStr,
    token: str,
    frontend_url: str = None
) -> None:
    """发送密码重置邮件"""
    # 默认使用后端URL，如果有前端URL则使用前端URL
    base_url = frontend_url or f"http://localhost:8000{settings.API_V1_STR}"
    reset_url = f"{base_url}/auth/reset-password?token={token}"
    expire_hours = settings.ACCESS_TOKEN_EXPIRE_MINUTES // 60
    
    template = Template(password_reset_template)
    html_content = template.render(
        reset_url=reset_url,
        expire_hours=expire_hours,
        project_name=settings.PROJECT_NAME
    )
    
    message = MessageSchema(
        subject=f"{settings.PROJECT_NAME} - 密码重置",
        recipients=[email_to],
        body=html_content,
        subtype="html"
    )
    
    await fastmail.send_message(message)


async def send_payment_confirmation(
    email_to: EmailStr,
    payment_info: Dict[str, Any]
) -> None:
    """发送支付确认邮件"""
    template = Template(payment_confirmation_template)
    html_content = template.render(
        payment_id=payment_info["id"],
        rental_id=payment_info["rental_id"],
        amount=payment_info["amount"],
        currency=payment_info["currency"],
        payment_date=payment_info["payment_date"],
        transaction_id=payment_info["transaction_id"] or "N/A",
        project_name=settings.PROJECT_NAME
    )
    
    message = MessageSchema(
        subject=f"{settings.PROJECT_NAME} - 支付确认",
        recipients=[email_to],
        body=html_content,
        subtype="html"
    )
    
    await fastmail.send_message(message)