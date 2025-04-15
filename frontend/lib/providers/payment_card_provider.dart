import 'package:flutter/material.dart';
import 'package:easy_scooter/services/payment_card_service.dart';
import 'package:easy_scooter/models/payment_card.dart';

class PaymentCardProvider extends ChangeNotifier {
  // 私有构造函数
  PaymentCardProvider._internal();
  // 单例实例
  static final PaymentCardProvider _instance = PaymentCardProvider._internal();
  // 工厂构造函数
  factory PaymentCardProvider() => _instance;

  List<PaymentCard> _paymentCards = [];
  // 加载状态
  bool _isLoading = false;
  // 错误信息
  String? _error;

  final PaymentCardService _paymentCardService = PaymentCardService();

  List<PaymentCard> get paymentCards => _paymentCards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPaymentCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final paymentCards = await _paymentCardService.getPaymentCards();
      _paymentCards = paymentCards;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '获取支付卡失败: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> addPaymentCard({
    required String holderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    String? cardType,
    bool? isDefault,
    bool? saveForFuture,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _paymentCardService.addPaymentCard(
        holderName: holderName,
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
        cardType: cardType,
        isDefault: isDefault ?? false,
        saveForFuture: saveForFuture ?? false,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = '添加支付卡失败: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
