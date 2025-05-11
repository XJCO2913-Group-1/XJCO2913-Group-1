import 'package:flutter/foundation.dart';

// Mock ScooterInfo 模型
class MockScooterInfo {
  final String id;
  String status;
  final String model;
  final double distance;
  final double rating;
  final double price;
  final String location;

  MockScooterInfo({
    required this.id,
    required this.status,
    required this.model,
    required this.distance,
    required this.rating,
    required this.price,
    required this.location,
  });
}

// Mock PaymentCard 模型
class MockPaymentCard {
  final String id;
  final String cardNumber;
  final String expiryDate;
  final String cardholderName;
  bool isDefault;

  MockPaymentCard({
    required this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardholderName,
    this.isDefault = false,
  });
}

// Mock Rental 模型
class MockRental {
  final String id;
  final String scooterId;
  final String paymentCardId;
  String status;

  MockRental({
    required this.id,
    required this.scooterId,
    required this.paymentCardId,
    required this.status,
  });
}

// Mock ScootersProvider
class MockScootersProvider extends ChangeNotifier {
  List<MockScooterInfo> _scooters = [];
  bool _isLoading = false;

  List<MockScooterInfo> get scooters => _scooters;
  bool get isLoading => _isLoading;

  Future<void> fetchScooters() async {
    _isLoading = true;
    notifyListeners();

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    _scooters = [
      MockScooterInfo(
        id: 'scooter_1',
        status: 'available',
        model: 'Model X',
        distance: 100.0,
        rating: 4.5,
        price: 10.0,
        location: 'Location 1',
      ),
      MockScooterInfo(
        id: 'scooter_2',
        status: 'available',
        model: 'Model Y',
        distance: 200.0,
        rating: 4.0,
        price: 12.0,
        location: 'Location 2',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  MockScooterInfo getScooterById(String id) {
    return _scooters.firstWhere(
      (scooter) => scooter.id == id,
      orElse: () => throw Exception('Scooter not found'),
    );
  }

  void updateScooterStatus(String id, String status) {
    final scooter = getScooterById(id);
    scooter.status = status;
    notifyListeners();
  }
}

// Mock PaymentCardProvider
class MockPaymentCardProvider extends ChangeNotifier {
  List<MockPaymentCard> _paymentCards = [];
  bool _isLoading = false;
  bool _isLoggedIn = false;

  List<MockPaymentCard> get paymentCards => _paymentCards;
  bool get isLoading => _isLoading;

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
  }

  Future<MockPaymentCard> addPaymentCard({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  }) async {
    if (!_isLoggedIn) {
      throw Exception('User not logged in');
    }

    if (cardNumber == 'invalid' || expiryDate == 'invalid' || cvv == 'invalid' || cardholderName.isEmpty) {
      throw Exception('Invalid card information');
    }

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final newCard = MockPaymentCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cardholderName: cardholderName,
    );

    _paymentCards.add(newCard);
    _isLoading = false;
    notifyListeners();

    return newCard;
  }

  Future<void> fetchPaymentCards() async {
    if (!_isLoggedIn) {
      throw Exception('User not logged in');
    }
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    // 只在没有卡时添加默认卡
    if (_paymentCards.isEmpty) {
      _paymentCards = [
        MockPaymentCard(
          id: '1',
          cardNumber: '4111111111111111',
          expiryDate: '12/25',
          cardholderName: 'Test User',
          isDefault: true,
        ),
      ];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setDefaultCard(String cardId) async {
    if (!_isLoggedIn) {
      throw Exception('User not logged in');
    }

    final card = _paymentCards.firstWhere(
      (card) => card.id == cardId,
      orElse: () => throw Exception('Card not found'),
    );

    for (var c in _paymentCards) {
      c.isDefault = c.id == cardId;
    }
    notifyListeners();
  }

  Future<void> updatePaymentCard({
    required String cardId,
    required String expiryDate,
    required String cardholderName,
  }) async {
    if (!_isLoggedIn) {
      throw Exception('User not logged in');
    }

    final index = _paymentCards.indexWhere((card) => card.id == cardId);
    if (index == -1) {
      throw Exception('Card not found');
    }
    final oldCard = _paymentCards[index];
    // 用新数据创建新卡片实例，保留 isDefault
    final updatedCard = MockPaymentCard(
      id: oldCard.id,
      cardNumber: oldCard.cardNumber,
      expiryDate: expiryDate,
      cardholderName: cardholderName,
      isDefault: oldCard.isDefault,
    );
    _paymentCards[index] = updatedCard;
    notifyListeners();
  }

  Future<void> deletePaymentCard(String cardId) async {
    if (!_isLoggedIn) {
      throw Exception('User not logged in');
    }

    final card = _paymentCards.firstWhere(
      (card) => card.id == cardId,
      orElse: () => throw Exception('Card not found'),
    );

    _paymentCards.remove(card);
    notifyListeners();
  }

  MockPaymentCard getCardById(String id) {
    return _paymentCards.firstWhere(
      (card) => card.id == id,
      orElse: () => throw Exception('Card not found'),
    );
  }
}

// Mock UserProvider
class MockUserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoggedIn = false;
    notifyListeners();
  }
}

// Mock RentalsProvider
class MockRentalsProvider extends ChangeNotifier {
  List<MockRental> _rentals = [];
  bool _isLoading = false;
  bool _isLoggedIn = false;
  MockScootersProvider? _scootersProvider;

  List<MockRental> get rentals => _rentals;
  bool get isLoading => _isLoading;

  MockRentalsProvider([MockScootersProvider? scootersProvider]) {
    _scootersProvider = scootersProvider;
  }

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
  }

  Future<MockRental> createRental({
    required String scooterId,
    required String paymentCardId,
  }) async {
    if (!_isLoggedIn) {
      throw Exception('User not logged in');
    }
    if (scooterId == 'non_existent_scooter') {
      throw Exception('Scooter not found');
    }
    if (paymentCardId == 'non_existent_card') {
      throw Exception('Payment card not found');
    }
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final rental = MockRental(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      scooterId: scooterId,
      paymentCardId: paymentCardId,
      status: 'active',
    );
    _rentals.add(rental);
    // 新增：同步滑板车状态
    _scootersProvider?.updateScooterStatus(scooterId, 'in_use');
    _isLoading = false;
    notifyListeners();
    return rental;
  }

  Future<void> endRental(String rentalId) async {
    if (!_isLoggedIn) {
      throw Exception('User not logged in');
    }
    final rental = _rentals.firstWhere(
      (rental) => rental.id == rentalId,
      orElse: () => throw Exception('Rental not found'),
    );
    rental.status = 'completed';
    // 新增：同步滑板车状态
    _scootersProvider?.updateScooterStatus(rental.scooterId, 'available');
    notifyListeners();
  }

  Future<MockRental> getRentalById(String rentalId) async {
    if (!_isLoggedIn) {
      throw Exception('User not logged in');
    }

    await Future.delayed(const Duration(milliseconds: 500));

    return _rentals.firstWhere(
      (rental) => rental.id == rentalId,
      orElse: () => throw Exception('Rental not found'),
    );
  }
} 