from typing import Any, Dict, Optional
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
from pydantic import EmailStr
from jinja2 import Template

from app.core.config import settings

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