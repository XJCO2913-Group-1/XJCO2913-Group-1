from typing import Dict, Any, Tuple
from datetime import datetime
import random
import string
from cryptography.fernet import Fernet

from app.core.config import settings
from app.models.payment import PaymentStatus

# 创建加密密钥
# 在实际应用中，这个密钥应该安全存储，而不是硬编码
# 这里为了演示，我们使用一个固定的密钥
PAYMENT_ENCRYPTION_KEY = (
    Fernet.generate_key()
    if not hasattr(settings, "PAYMENT_ENCRYPTION_KEY")
    else settings.PAYMENT_ENCRYPTION_KEY
)
cipher_suite = Fernet(PAYMENT_ENCRYPTION_KEY)


def encrypt_card_data(data: str) -> str:
    """
    加密卡数据
    """
    if not data:
        return ""
    encrypted_data = cipher_suite.encrypt(data.encode())
    return encrypted_data.decode()


def decrypt_card_data(encrypted_data: str) -> str:
    """
    解密卡数据
    """
    if not encrypted_data:
        return ""
    decrypted_data = cipher_suite.decrypt(encrypted_data.encode())
    return decrypted_data.decode()


def get_card_type(card_number: str) -> str:
    """
    根据卡号前缀确定卡类型
    """
    card_number = card_number.replace(" ", "").replace("-", "")

    # 简化的卡类型检测
    if card_number.startswith("4"):
        return "Visa"
    elif card_number.startswith(("51", "52", "53", "54", "55")):
        return "MasterCard"
    elif card_number.startswith(("34", "37")):
        return "American Express"
    elif card_number.startswith("6"):
        return "Discover"
    elif card_number.startswith(("62", "81")):
        return "UnionPay"
    else:
        return "Unknown"


def validate_card(
    card_number: str, expiry_month: str, expiry_year: str, cvv: str
) -> Tuple[bool, str]:
    """
    Validate card information
    """
    # Check if the card number is valid (simplified Luhn algorithm check)
    if not is_valid_card_number(card_number):
        return False, "Invalid card number"

    # Check expiration date
    current_year = (
        datetime.now().year % 100
    )  # Get the last two digits of the current year
    current_month = datetime.now().month

    expiry_year_int = int(expiry_year)
    expiry_month_int = int(expiry_month)

    if expiry_year_int < current_year or (
        expiry_year_int == current_year and expiry_month_int < current_month
    ):
        return False, "Card has expired"

    # Check CVV length
    card_type = get_card_type(card_number)
    if card_type == "American Express" and len(cvv) != 4:
        return False, "American Express cards must have a 4-digit CVV"
    elif card_type != "American Express" and len(cvv) != 3:
        return False, "CVV must be 3 digits"

    return True, "Card validation successful"


def is_valid_card_number(card_number: str) -> bool:
    """
    Validate card number using the Luhn algorithm
    """
    # Remove spaces and dashes
    card_number = card_number.replace(" ", "").replace("-", "")

    # Check if it contains only digits
    if not card_number.isdigit():
        return False

    # Check length
    if not (13 <= len(card_number) <= 19):
        return False

    # Luhn algorithm
    digits = [int(d) for d in card_number]
    odd_digits = digits[-1::-2]  # Odd digits from right to left
    even_digits = digits[-2::-2]  # Even digits from right to left

    # Double the even digits, subtract 9 if the result is greater than 9
    doubled_digits = []
    for d in even_digits:
        doubled = d * 2
        if doubled > 9:
            doubled -= 9
        doubled_digits.append(doubled)

    # Sum all digits
    total = sum(odd_digits) + sum(doubled_digits)

    # If the total is divisible by 10, the card number is valid
    return total % 10 == 0


def process_payment(
    amount: float, card_data: Dict[str, Any] = None, saved_card_id: int = None
) -> Dict[str, Any]:
    """
    Simulate payment processing
    In a real application, this would call an actual payment gateway API
    """
    # Simulate payment processing delay
    # time.sleep(1)

    if amount <= 0:
        return {
            "success": False,
            "status": PaymentStatus.FAILED,
            "message": "Payment amount must be greater than 0",
        }

    # Generate a random transaction ID
    transaction_id = "".join(
        random.choices(string.ascii_uppercase + string.digits, k=12)
    )

    # Simulate payment success rate (95% success)
    success = random.random() < 0.95

    if success:
        return {
            "success": True,
            "transaction_id": transaction_id,
            "status": PaymentStatus.COMPLETED,
            "message": "Payment successful",
        }
    else:
        error_codes = [
            "insufficient_funds",
            "card_declined",
            "expired_card",
            "invalid_cvc",
        ]
        error_code = random.choice(error_codes)
        error_messages = {
            "insufficient_funds": "Insufficient funds",
            "card_declined": "Card declined",
            "expired_card": "Card has expired",
            "invalid_cvc": "Invalid security code",
        }

        return {
            "success": False,
            "error_code": error_code,
            "error_message": error_messages[error_code],
            "status": PaymentStatus.FAILED,
            "message": f"Payment failed: {error_messages[error_code]}",
        }
