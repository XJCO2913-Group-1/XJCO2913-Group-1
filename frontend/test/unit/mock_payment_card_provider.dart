import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/providers/payment_card_provider.dart';
import 'package:easy_scooter/models/payment_card.dart';
import 'package:flutter/material.dart';

class MockPaymentCardProvider extends ChangeNotifier implements PaymentCardProvider {
  List<PaymentCard> _paymentCards = [];
  bool _isLoading = false;
  String? _error;

  @override
  List<PaymentCard> get paymentCards => _paymentCards;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;

  @override
  Future<void> fetchPaymentCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _paymentCards = [
    PaymentCard(
      id: 1,
          cardHolerName: '测试用户1',
      cardNumberLast4: '1234',
      cardExpiryMonth: '12',
      cardExpiryYear: '30',
      cardType: 'VISA',
      isDefault: true,
    ),
        PaymentCard(
          id: 2,
          cardHolerName: '测试用户2',
          cardNumberLast4: '5678',
          cardExpiryMonth: '06',
          cardExpiryYear: '25',
          cardType: 'MASTERCARD',
          isDefault: false,
        ),
      ];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '获取支付卡失败: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
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
      // 验证卡号格式
      if (!_isValidCardNumber(cardNumber)) {
        throw Exception('无效的卡号格式');
      }

      // 验证过期日期
      if (!_isValidExpiryDate(expiryMonth, expiryYear)) {
        throw Exception('无效的过期日期');
      }

      // 验证CVV
      if (!_isValidCVV(cvv)) {
        throw Exception('无效的CVV');
      }

      // 如果设置为默认卡，将其他卡设为非默认
      if (isDefault == true) {
        _paymentCards = _paymentCards.map((card) => PaymentCard(
          id: card.id,
          cardHolerName: card.cardHolerName,
          cardNumberLast4: card.cardNumberLast4,
          cardExpiryMonth: card.cardExpiryMonth,
          cardExpiryYear: card.cardExpiryYear,
          cardType: card.cardType,
          isDefault: false,
        )).toList();
      }

      final newCard = PaymentCard(
        id: _paymentCards.length + 1,
        cardHolerName: holderName,
        cardNumberLast4: cardNumber.substring(cardNumber.length - 4),
        cardExpiryMonth: expiryMonth,
        cardExpiryYear: expiryYear,
        cardType: cardType ?? _detectCardType(cardNumber),
        isDefault: isDefault ?? false,
      );
      _paymentCards.add(newCard);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = '添加支付卡失败: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  @override
  Future<bool> setDefaultCard(int cardId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final card = _paymentCards.firstWhere((c) => c.id == cardId);
      _paymentCards = _paymentCards.map((c) => PaymentCard(
        id: c.id,
        cardHolerName: c.cardHolerName,
        cardNumberLast4: c.cardNumberLast4,
        cardExpiryMonth: c.cardExpiryMonth,
        cardExpiryYear: c.cardExpiryYear,
        cardType: c.cardType,
        isDefault: c.id == cardId,
      )).toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = '设置默认卡失败: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  @override
  Future<bool> deleteCard(int cardId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final card = _paymentCards.firstWhere((c) => c.id == cardId);
      if (card.isDefault && _paymentCards.length > 1) {
        // 如果删除的是默认卡，将第一张非默认卡设为默认
        final nextDefault = _paymentCards.firstWhere((c) => c.id != cardId);
        _paymentCards = _paymentCards.where((c) => c.id != cardId).map((c) => PaymentCard(
          id: c.id,
          cardHolerName: c.cardHolerName,
          cardNumberLast4: c.cardNumberLast4,
          cardExpiryMonth: c.cardExpiryMonth,
          cardExpiryYear: c.cardExpiryYear,
          cardType: c.cardType,
          isDefault: c.id == nextDefault.id,
        )).toList();
      } else {
        _paymentCards = _paymentCards.where((c) => c.id != cardId).toList();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = '删除支付卡失败: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // 辅助方法：验证卡号
  bool _isValidCardNumber(String cardNumber) {
    // 简单的卡号验证：16-19位数字
    return RegExp(r'^\d{16,19}$').hasMatch(cardNumber);
  }

  // 辅助方法：验证过期日期
  bool _isValidExpiryDate(String month, String year) {
    try {
      final expMonth = int.parse(month);
      final expYear = int.parse(year);
      final now = DateTime.now();
      final currentYear = now.year % 100; // 获取年份后两位
      
      if (expMonth < 1 || expMonth > 12) return false;
      if (expYear < currentYear) return false;
      if (expYear == currentYear && expMonth < now.month) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // 辅助方法：验证CVV
  bool _isValidCVV(String cvv) {
    // CVV通常是3-4位数字
    return RegExp(r'^\d{3,4}$').hasMatch(cvv);
  }

  // 辅助方法：检测卡类型
  String _detectCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'VISA';
    if (cardNumber.startsWith('5')) return 'MASTERCARD';
    if (cardNumber.startsWith('3')) return 'AMEX';
    return 'UNKNOWN';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('MockPaymentCardProvider 测试', () {
    late MockPaymentCardProvider provider;

    setUp(() {
      provider = MockPaymentCardProvider();
    });

    test('基本属性', () {
      expect(provider.paymentCards.length, 0);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('fetchPaymentCards 成功', () async {
      await provider.fetchPaymentCards();
      expect(provider.paymentCards.length, 2);
      expect(provider.paymentCards.first.cardHolerName, '测试用户1');
      expect(provider.paymentCards.first.cardNumberLast4, '1234');
      expect(provider.paymentCards.first.isDefault, true);
      expect(provider.paymentCards.last.cardHolerName, '测试用户2');
      expect(provider.paymentCards.last.cardNumberLast4, '5678');
      expect(provider.paymentCards.last.isDefault, false);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('addPaymentCard 成功 - VISA卡', () async {
      final result = await provider.addPaymentCard(
        holderName: '新用户',
        cardNumber: '4111111111111111',
        expiryMonth: '12',
        expiryYear: '25',
        cvv: '123',
        cardType: 'VISA',
        isDefault: true,
      );
      
      expect(result, true);
      expect(provider.paymentCards.length, 1);
      expect(provider.paymentCards.first.cardHolerName, '新用户');
      expect(provider.paymentCards.first.cardNumberLast4, '1111');
      expect(provider.paymentCards.first.cardType, 'VISA');
      expect(provider.paymentCards.first.isDefault, true);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('addPaymentCard 成功 - MASTERCARD', () async {
      final result = await provider.addPaymentCard(
        holderName: '新用户',
        cardNumber: '5111111111111111',
        expiryMonth: '12',
        expiryYear: '25',
        cvv: '123',
      );
      
      expect(result, true);
      expect(provider.paymentCards.first.cardType, 'MASTERCARD');
    });

    test('addPaymentCard 失败 - 无效的卡号', () async {
      final result = await provider.addPaymentCard(
        holderName: '新用户',
        cardNumber: '123', // 无效的卡号
        expiryMonth: '12',
        expiryYear: '25',
        cvv: '123',
      );
      
      expect(result, false);
      expect(provider.paymentCards.length, 0);
      expect(provider.error, isNotNull);
    });

    test('addPaymentCard 失败 - 无效的过期日期', () async {
      final result = await provider.addPaymentCard(
        holderName: '新用户',
        cardNumber: '4111111111111111',
        expiryMonth: '13', // 无效的月份
        expiryYear: '25',
        cvv: '123',
      );
      
      expect(result, false);
      expect(provider.paymentCards.length, 0);
      expect(provider.error, isNotNull);
    });

    test('addPaymentCard 失败 - 过期的卡', () async {
      final result = await provider.addPaymentCard(
        holderName: '新用户',
        cardNumber: '4111111111111111',
        expiryMonth: '01',
        expiryYear: '20', // 过期的年份
        cvv: '123',
      );
      
      expect(result, false);
      expect(provider.paymentCards.length, 0);
      expect(provider.error, isNotNull);
    });

    test('addPaymentCard 失败 - 无效的CVV', () async {
      final result = await provider.addPaymentCard(
        holderName: '新用户',
        cardNumber: '4111111111111111',
        expiryMonth: '12',
        expiryYear: '25',
        cvv: '12', // 无效的CVV
      );
      
      expect(result, false);
      expect(provider.paymentCards.length, 0);
      expect(provider.error, isNotNull);
    });

    test('setDefaultCard 成功', () async {
      await provider.fetchPaymentCards();
      final result = await provider.setDefaultCard(2);
      
      expect(result, true);
      expect(provider.paymentCards.first.isDefault, false);
      expect(provider.paymentCards.last.isDefault, true);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('setDefaultCard 失败 - 不存在的卡ID', () async {
      await provider.fetchPaymentCards();
      final result = await provider.setDefaultCard(999);
      
      expect(result, false);
      expect(provider.error, isNotNull);
    });

    test('deleteCard 成功', () async {
      await provider.fetchPaymentCards();
      final result = await provider.deleteCard(1);
      
      expect(result, true);
    expect(provider.paymentCards.length, 1);
      expect(provider.paymentCards.first.id, 2);
      expect(provider.paymentCards.first.isDefault, true);
    expect(provider.isLoading, false);
    expect(provider.error, null);
    });

    test('deleteCard 失败 - 不存在的卡ID', () async {
      await provider.fetchPaymentCards();
      final result = await provider.deleteCard(999);
      
      expect(result, false);
      expect(provider.error, isNotNull);
    });

    test('删除默认卡后自动设置新的默认卡', () async {
      await provider.fetchPaymentCards();
      await provider.deleteCard(1);
      
      expect(provider.paymentCards.length, 1);
      expect(provider.paymentCards.first.isDefault, true);
    });

    test('添加新默认卡时更新其他卡的默认状态', () async {
      await provider.fetchPaymentCards();
      await provider.addPaymentCard(
        holderName: '新用户',
        cardNumber: '4111111111111111',
        expiryMonth: '12',
        expiryYear: '25',
        cvv: '123',
        isDefault: true,
      );
      
      expect(provider.paymentCards.length, 3);
      expect(provider.paymentCards.last.isDefault, true);
      expect(provider.paymentCards.where((c) => c.isDefault).length, 1);
    });
  });
} 