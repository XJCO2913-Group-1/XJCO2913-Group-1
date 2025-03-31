from typing import Dict, Any, Optional, Tuple
from datetime import datetime
import random
import string
from cryptography.fernet import Fernet

from app.core.config import settings
from app.models.payment import PaymentStatus

# 创建加密密钥
# 在实际应用中，这个密钥应该安全存储，而不是硬编码
# 这里为了演示，我们使用一个固定的密钥
PAYMENT_ENCRYPTION_KEY = Fernet.generate_key() if not hasattr(settings, 'PAYMENT_ENCRYPTION_KEY') else settings.PAYMENT_ENCRYPTION_KEY
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
    card_number = card_number.replace(' ', '').replace('-', '')
    
    # 简化的卡类型检测
    if card_number.startswith('4'):
        return 'Visa'
    elif card_number.startswith(('51', '52', '53', '54', '55')):
        return 'MasterCard'
    elif card_number.startswith(('34', '37')):
        return 'American Express'
    elif card_number.startswith('6'):
        return 'Discover'
    elif card_number.startswith(('62', '81')):
        return 'UnionPay'
    else:
        return 'Unknown'


def validate_card(card_number: str, expiry_month: str, expiry_year: str, cvv: str) -> Tuple[bool, str]:
    """
    验证卡信息
    """
    # 检查卡号是否有效（简化的Luhn算法检查）
    if not is_valid_card_number(card_number):
        return False, "无效的卡号"
    
    # 检查过期日期
    current_year = datetime.now().year % 100  # 获取当前年份的后两位
    current_month = datetime.now().month
    
    expiry_year_int = int(expiry_year)
    expiry_month_int = int(expiry_month)
    
    if expiry_year_int < current_year or (expiry_year_int == current_year and expiry_month_int < current_month):
        return False, "卡已过期"
    
    # 检查CVV长度
    card_type = get_card_type(card_number)
    if card_type == 'American Express' and len(cvv) != 4:
        return False, "American Express卡的CVV必须是4位"
    elif card_type != 'American Express' and len(cvv) != 3:
        return False, "CVV必须是3位"
    
    return True, "卡验证通过"


def is_valid_card_number(card_number: str) -> bool:
    """
    使用Luhn算法验证卡号
    """
    # 移除空格和破折号
    card_number = card_number.replace(' ', '').replace('-', '')
    
    # 检查是否只包含数字
    if not card_number.isdigit():
        return False
    
    # 检查长度
    if not (13 <= len(card_number) <= 19):
        return False
    
    # Luhn算法
    digits = [int(d) for d in card_number]
    odd_digits = digits[-1::-2]  # 从右向左，奇数位
    even_digits = digits[-2::-2]  # 从右向左，偶数位
    
    # 偶数位数字乘以2，如果结果大于9，则减去9
    doubled_digits = []
    for d in even_digits:
        doubled = d * 2
        if doubled > 9:
            doubled -= 9
        doubled_digits.append(doubled)
    
    # 所有数字相加
    total = sum(odd_digits) + sum(doubled_digits)
    
    # 如果总和能被10整除，则卡号有效
    return total % 10 == 0


def process_payment(amount: float, card_data: Dict[str, Any] = None, saved_card_id: int = None) -> Dict[str, Any]:
    """
    模拟支付处理
    在实际应用中，这里会调用真实的支付网关API
    """
    # 模拟支付处理延迟
    # time.sleep(1)

    if amount <= 0:
        return {
            "success": False,
            "status": PaymentStatus.FAILED,
            "message": "支付金额必须大于0"
        }
    
    # 生成随机交易ID
    transaction_id = ''.join(random.choices(string.ascii_uppercase + string.digits, k=12))
    
    # 模拟支付成功率 (95%成功)
    success = random.random() < 0.95
    
    if success:
        return {
            "success": True,
            "transaction_id": transaction_id,
            "status": PaymentStatus.COMPLETED,
            "message": "支付成功"
        }
    else:
        error_codes = ["insufficient_funds", "card_declined", "expired_card", "invalid_cvc"]
        error_code = random.choice(error_codes)
        error_messages = {
            "insufficient_funds": "余额不足",
            "card_declined": "卡被拒绝",
            "expired_card": "卡已过期",
            "invalid_cvc": "无效的安全码"
        }
        
        return {
            "success": False,
            "error_code": error_code,
            "error_message": error_messages[error_code],
            "status": PaymentStatus.FAILED,
            "message": f"支付失败: {error_messages[error_code]}"
        }