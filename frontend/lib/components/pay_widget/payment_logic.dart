import 'package:flutter/material.dart';
import 'package:easy_scooter/models/payment_card.dart';

class PaymentLogic {
  // 获取默认支付卡（isDefault=true），如果没有则返回第一张卡
  static PaymentCard getDefaultCard(List<PaymentCard> cards) {
    for (var card in cards) {
      if (card.isDefault == true) {
        return card;
      }
    }
    return cards.first; // 如果没有默认卡，返回第一张卡
  }

  // 处理支付逻辑
  static Future<void> processPayment({
    required BuildContext context,
    required PaymentCard? selectedCard,
    required VoidCallback onPaymentStarted,
    required VoidCallback onPaymentCompleted,
  }) async {
    if (selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a payment card')));
      return;
    }

    onPaymentStarted();

    try {
      // 这里应该实现实际的支付处理逻辑
      // 现在仅用延迟来模拟异步支付过程
      await Future.delayed(const Duration(seconds: 2));
      // 支付成功后的操作
      onPaymentCompleted();
    } catch (e) {
      // 处理支付过程中可能出现的错误
      onPaymentCompleted();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${e.toString()}')));
    }
  }
}
