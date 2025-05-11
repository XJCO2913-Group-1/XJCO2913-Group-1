import 'package:flutter_test/flutter_test.dart';
import 'mocks/mock_providers.dart';

void main() {
  group('支付流程系统测试', () {
    late MockPaymentCardProvider paymentCardProvider;
    late MockUserProvider userProvider;
    late MockRentalsProvider rentalsProvider;

    setUp(() {
      paymentCardProvider = MockPaymentCardProvider();
      userProvider = MockUserProvider();
      rentalsProvider = MockRentalsProvider();
    });

    test('完整的支付卡管理流程测试', () async {
      // 1. 用户登录
      await userProvider.login('test@example.com', 'password123');
      expect(userProvider.isLoggedIn, true);
      paymentCardProvider.setLoggedIn(true);

      // 2. 添加新支付卡
      final newCard = await paymentCardProvider.addPaymentCard(
        cardNumber: '4111111111111111',
        expiryDate: '12/25',
        cvv: '123',
        cardholderName: 'Test User',
      );
      expect(newCard.cardNumber, '4111111111111111');

      // 3. 设置默认卡
      await paymentCardProvider.setDefaultCard(newCard.id);
      final updatedCard = paymentCardProvider.getCardById(newCard.id);
      expect(updatedCard.isDefault, true);

      // 4. 更新支付卡信息
      await paymentCardProvider.updatePaymentCard(
        cardId: newCard.id,
        expiryDate: '12/26',
        cardholderName: 'Updated User',
      );
      final updatedCardInfo = paymentCardProvider.getCardById(newCard.id);
      expect(updatedCardInfo.expiryDate, '12/26');
      expect(updatedCardInfo.cardholderName, 'Updated User');

      // 5. 删除支付卡
      await paymentCardProvider.deletePaymentCard(newCard.id);
      expect(paymentCardProvider.paymentCards.isEmpty, true);
    });

    test('支付流程异常处理测试', () async {
      // 1. 未登录用户尝试添加支付卡
      expect(
        () => paymentCardProvider.addPaymentCard(
          cardNumber: '4111111111111111',
          expiryDate: '12/25',
          cvv: '123',
          cardholderName: 'Test User',
        ),
        throwsException,
      );

      // 2. 添加无效的支付卡信息
      await userProvider.login('test@example.com', 'password123');
      paymentCardProvider.setLoggedIn(true);
      expect(
        () => paymentCardProvider.addPaymentCard(
          cardNumber: 'invalid',
          expiryDate: 'invalid',
          cvv: 'invalid',
          cardholderName: '',
        ),
        throwsException,
      );

      // 3. 更新不存在的支付卡
      expect(
        () => paymentCardProvider.updatePaymentCard(
          cardId: 'non_existent_id',
          expiryDate: '12/26',
          cardholderName: 'Test User',
        ),
        throwsException,
      );
    });
  });
} 