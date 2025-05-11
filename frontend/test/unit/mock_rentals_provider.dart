import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/providers/rentals_provider.dart';
import 'package:easy_scooter/models/rental.dart';
import 'package:flutter/material.dart';

class MockRentalsProvider extends ChangeNotifier implements RentalsProvider {
  List<Rental> _rentals = [];
  bool _isLoading = false;
  String? _error;

  @override
  List<Rental> get rentals => _rentals;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;

  @override
  Future<void> fetchRentals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rentals = [
        Rental(
          id: 1,
          scooterId: 1,
          scooterName: '测试滑板车1',
          startTime: DateTime.parse('2024-03-20 10:00:00'),
          endTime: DateTime.parse('2024-03-20 11:00:00'),
          status: 'active',
          cost: 10.0,
          rentalPeriod: '1h',
          location: '测试地点1',
        ),
        Rental(
          id: 2,
          scooterId: 2,
          scooterName: '测试滑板车2',
          startTime: DateTime.parse('2024-03-20 14:00:00'),
          endTime: DateTime.parse('2024-03-20 15:00:00'),
          status: 'completed',
          cost: 15.0,
          rentalPeriod: '1h',
          location: '测试地点2',
        ),
      ];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '获取租赁记录失败: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  Future<bool> createRental({
    required int scooterId,
    required String rentalPeriod,
    int? userId,
    String? startTime,
    String? endTime,
    String? status,
    double? cost,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRental = Rental(
        id: _rentals.length + 1,
        scooterId: scooterId,
        scooterName: '新滑板车',
        startTime: startTime != null ? DateTime.parse(startTime) : DateTime.now(),
        endTime: endTime != null ? DateTime.parse(endTime) : DateTime.now().add(const Duration(hours: 1)),
        status: status ?? 'active',
        cost: cost ?? 10.0,
        rentalPeriod: rentalPeriod,
        location: '新地点',
      );
      _rentals.add(newRental);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = '创建租赁记录失败: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('MockRentalsProvider 测试', () {
    late MockRentalsProvider provider;

    setUp(() {
      provider = MockRentalsProvider();
    });

    test('基本属性', () {
      expect(provider.rentals.length, 0);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('fetchRentals 成功', () async {
      await provider.fetchRentals();
      expect(provider.rentals.length, 2);
      expect(provider.rentals.first.scooterName, '测试滑板车1');
      expect(provider.rentals.first.status, 'active');
      expect(provider.rentals.last.scooterName, '测试滑板车2');
      expect(provider.rentals.last.status, 'completed');
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('createRental 成功', () async {
      final result = await provider.createRental(
        scooterId: 3,
        rentalPeriod: '1h',
        startTime: '2024-03-21 10:00:00',
        endTime: '2024-03-21 11:00:00',
        status: 'active',
        cost: 20.0,
      );
      
      expect(result, true);
      expect(provider.rentals.length, 1);
      expect(provider.rentals.first.scooterId, 3);
      expect(provider.rentals.first.rentalPeriod, '1h');
      expect(provider.rentals.first.cost, 20.0);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('createRental 失败 - 无效的时间格式', () async {
      final result = await provider.createRental(
        scooterId: 3,
        rentalPeriod: '1h',
        startTime: 'invalid_time',
        endTime: 'invalid_time',
      );
      
      expect(result, false);
      expect(provider.rentals.length, 0);
      expect(provider.error, isNotNull);
    });

    test('租赁记录属性验证', () async {
      await provider.fetchRentals();
      final rental = provider.rentals.first;
      
      expect(rental.id, 1);
      expect(rental.scooterId, 1);
      expect(rental.scooterName, '测试滑板车1');
      expect(rental.startTime, DateTime.parse('2024-03-20 10:00:00'));
      expect(rental.endTime, DateTime.parse('2024-03-20 11:00:00'));
      expect(rental.status, 'active');
      expect(rental.cost, 10.0);
      expect(rental.rentalPeriod, '1h');
      expect(rental.location, '测试地点1');
    });

    test('不同状态的租赁记录', () async {
      await provider.fetchRentals();
      
      final activeRentals = provider.rentals.where((r) => r.status == 'active').toList();
      final completedRentals = provider.rentals.where((r) => r.status == 'completed').toList();
      
      expect(activeRentals.length, 1);
      expect(completedRentals.length, 1);
      expect(activeRentals.first.id, 1);
      expect(completedRentals.first.id, 2);
    });
  });
} 