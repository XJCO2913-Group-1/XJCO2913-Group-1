from typing import Any, Dict
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
    USE_CREDENTIALS=True,
)


fastmail = FastMail(conf)

rental_confirmation_template = """
<p>Dear User,</p>
<p>Your electric scooter rental order has been confirmed. Details are as follows:</p>
<ul>
    <li>Order ID: {{ rental_id }}</li>
    <li>Scooter ID: {{ scooter_id }}</li>
    <li>Rental Start Time: {{ start_time }}</li>
    <li>Rental End Time: {{ end_time }}</li>
    <li>Rental Cost: ¥{{ total_cost }}</li>
</ul>
<p>We wish you a pleasant experience!</p>
<p>{{ project_name }} Team</p>
"""

password_reset_template = """
<p>Dear User,</p>
<p>You recently requested to reset your password. Please click the link below to reset your password:</p>
<p><a href="{{ reset_url }}">Reset Password</a></p>
<p>If you did not request a password reset, please ignore this email.</p>
<p>This link will expire in {{ expire_hours }} hours.</p>
<p>{{ project_name }} Team</p>
"""

payment_confirmation_template = """
<p>Dear User,</p>
<p>Your payment has been successfully processed. Details are as follows:</p>
<ul>
    <li>Payment ID: {{ payment_id }}</li>
    <li>Order ID: {{ rental_id }}</li>
    <li>Payment Amount: {{ currency }} {{ amount }}</li>
    <li>Payment Date: {{ payment_date }}</li>
    <li>Transaction ID: {{ transaction_id }}</li>
</ul>
<p>Thank you for using our service!</p>
<p>{{ project_name }} Team</p>
"""

# Add a HTML password reset form template
password_reset_form_template = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ project_name }} - Reset Password</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            max-width: 500px;
            margin: 0 auto;
            padding: 20px;
        }
        .container {
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 20px;
            margin-top: 30px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="password"] {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .btn {
            background-color: #4CAF50;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
        }
        .btn:hover {
            background-color: #45a049;
        }
        .error {
            color: red;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Reset Your Password</h1>
        <p>Please enter your new password below:</p>
        <form id="resetForm" action="{{ submit_url }}" method="post">
            <input type="hidden" name="token" value="{{ token }}">
            <div class="form-group">
                <label for="password">New Password:</label>
                <input type="password" id="password" name="password" required minlength="8">
            </div>
            <div class="form-group">
                <label for="confirm_password">Confirm Password:</label>
                <input type="password" id="confirm_password" name="confirm_password" required minlength="8">
            </div>
            <div class="error" id="error"></div>
            <button type="submit" class="btn">Reset Password</button>
        </form>
    </div>

    <script>
        document.getElementById('resetForm').addEventListener('submit', function(e) {
            var password = document.getElementById('password').value;
            var confirmPassword = document.getElementById('confirm_password').value;
            var error = document.getElementById('error');
            
            if (password !== confirmPassword) {
                e.preventDefault();
                error.textContent = 'Passwords do not match!';
            } else {
                error.textContent = '';
            }
        });
    </script>
</body>
</html>
"""


async def send_rental_confirmation(
    email_to: EmailStr, rental_info: Dict[str, Any]
) -> None:
    """发送租赁确认邮件"""
    template = Template(rental_confirmation_template)
    html_content = template.render(
        rental_id=rental_info["id"],
        scooter_id=rental_info["scooter_id"],
        start_time=rental_info["start_time"],
        end_time=rental_info["end_time"],
        total_cost=rental_info["total_cost"],
        project_name=settings.PROJECT_NAME,
    )

    message = MessageSchema(
        subject=f"{settings.PROJECT_NAME} - Rental Confirmation",
        recipients=[email_to],
        body=html_content,
        subtype="html",
    )

    await fastmail.send_message(message)


async def send_password_reset_email(
    email_to: EmailStr,
    token: str,
) -> None:
    """Send password reset email"""
    # Use backend URL directly since we'll handle the reset in the backend
    server_url = str(settings.SERVER_URL)
    if server_url.endswith("/"):
        server_url = server_url[:-1]
    base_url = f"{server_url}{settings.API_V1_STR}"
    reset_url = f"{base_url}/auth/reset-password-form?token={token}"
    expire_hours = settings.ACCESS_TOKEN_EXPIRE_MINUTES // 60

    template = Template(password_reset_template)
    html_content = template.render(
        reset_url=reset_url,
        expire_hours=expire_hours,
        project_name=settings.PROJECT_NAME,
    )

    message = MessageSchema(
        subject=f"{settings.PROJECT_NAME} - Password Reset",
        recipients=[email_to],
        body=html_content,
        subtype="html",
    )

    await fastmail.send_message(message)


async def send_payment_confirmation(
    email_to: EmailStr, payment_info: Dict[str, Any]
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
        project_name=settings.PROJECT_NAME,
    )

    message = MessageSchema(
        subject=f"{settings.PROJECT_NAME} - 支付确认",
        recipients=[email_to],
        body=html_content,
        subtype="html",
    )

    await fastmail.send_message(message)
