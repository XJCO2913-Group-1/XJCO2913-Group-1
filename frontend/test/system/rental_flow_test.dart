import 'package:flutter_test/flutter_test.dart';
import 'mocks/mock_providers.dart';

void main() {
  group('租赁流程系统测试', () {
    late MockScootersProvider scooterProvider;
    late MockPaymentCardProvider paymentCardProvider;
    late MockRentalsProvider rentalsProvider;
    late MockUserProvider userProvider;

    setUp(() {
      scooterProvider = MockScootersProvider();
      paymentCardProvider = MockPaymentCardProvider();
      rentalsProvider = MockRentalsProvider(scooterProvider);
      userProvider = MockUserProvider();
    });

    test('完整的租赁流程测试', () async {
      // 1. 用户登录
      await userProvider.login('test@example.com', 'password123');
      expect(userProvider.isLoggedIn, true);
      paymentCardProvider.setLoggedIn(true);
      rentalsProvider.setLoggedIn(true);

      // 2. 获取可用滑板车列表
      await scooterProvider.fetchScooters();
      expect(scooterProvider.scooters.isNotEmpty, true);

      // 3. 添加支付卡
      final paymentCard = await paymentCardProvider.addPaymentCard(
        cardNumber: '4111111111111111',
        expiryDate: '12/25',
        cvv: '123',
        cardholderName: 'Test User',
      );

      // 4. 创建租赁
      final scooter = scooterProvider.scooters.first;
      final rental = await rentalsProvider.createRental(
        scooterId: scooter.id,
        paymentCardId: paymentCard.id,
      );
      expect(rental.scooterId, scooter.id);
      expect(rental.status, 'active');

      // 5. 检查滑板车状态
      final updatedScooter = scooterProvider.getScooterById(scooter.id);
      expect(updatedScooter.status, 'in_use');

      // 6. 结束租赁
      await rentalsProvider.endRental(rental.id);
      final endedRental = await rentalsProvider.getRentalById(rental.id);
      expect(endedRental.status, 'completed');

      // 7. 再次检查滑板车状态
      final finalScooter = scooterProvider.getScooterById(scooter.id);
      expect(finalScooter.status, 'available');
    });

    test('租赁流程异常处理测试', () async {
      // 1. 未登录用户尝试创建租赁
      expect(
        () => rentalsProvider.createRental(
          scooterId: 'scooter_1',
          paymentCardId: 'card_1',
        ),
        throwsException,
      );

      // 2. 使用不存在的滑板车ID
      await userProvider.login('test@example.com', 'password123');
      paymentCardProvider.setLoggedIn(true);
      rentalsProvider.setLoggedIn(true);
      expect(
        () => rentalsProvider.createRental(
          scooterId: 'non_existent_scooter',
          paymentCardId: 'card_1',
        ),
        throwsException,
      );

      // 3. 使用不存在的支付卡ID
      expect(
        () => rentalsProvider.createRental(
          scooterId: 'scooter_1',
          paymentCardId: 'non_existent_card',
        ),
        throwsException,
      );
    });
  });
} 