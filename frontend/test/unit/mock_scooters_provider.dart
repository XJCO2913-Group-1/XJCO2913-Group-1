import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/providers/scooters_provider.dart';
import 'package:easy_scooter/models/scooter.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class MockScootersProvider extends ChangeNotifier implements ScootersProvider {
  List<ScooterInfo> _scooters = [];
  bool _isLoading = false;
  String? _error;

  @override
  List<ScooterInfo> get scooters => _scooters;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;

  @override
  Future<void> fetchScooters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _scooters = [
        ScooterInfo(
          id: 1,
          model: 'Model A',
          distance: 0.0,
          location: 'Test Location',
          rating: 4.5,
          status: 'available',
          latLng: LatLng(39.9042, 116.4074),
          price: 10.0,
        ),
        ScooterInfo(
          id: 2,
          model: 'Model B',
          distance: 100.0,
          location: 'Another Location',
          rating: 4.0,
          status: 'in_use',
          latLng: LatLng(39.9142, 116.4174),
          price: 15.0,
        ),
        ScooterInfo(
          id: 3,
          model: 'Model C',
          distance: 200.0,
          location: 'Far Location',
          rating: 3.5,
          status: 'maintenance',
          latLng: LatLng(39.9242, 116.4274),
          price: 20.0,
        ),
      ];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '获取滑板车数据失败: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  Future<void> refreshScooters() async {
    await fetchScooters();
  }

  @override
  Future<ScooterInfo?> getScooter(int id) async {
    try {
      return _scooters.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // 模拟更新滑板车状态
  Future<bool> updateScooterStatus(int id, String newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _scooters.indexWhere((s) => s.id == id);
      if (index == -1) {
        throw Exception('滑板车不存在');
      }

      if (!['available', 'in_use', 'maintenance'].contains(newStatus)) {
        throw Exception('无效的状态');
      }

      _scooters[index] = ScooterInfo(
        id: _scooters[index].id,
        model: _scooters[index].model,
        distance: _scooters[index].distance,
        location: _scooters[index].location,
        rating: _scooters[index].rating,
        status: newStatus,
        latLng: _scooters[index].latLng,
        price: _scooters[index].price,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = '更新滑板车状态失败: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // 模拟更新滑板车位置
  Future<bool> updateScooterLocation(int id, LatLng newLocation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _scooters.indexWhere((s) => s.id == id);
      if (index == -1) {
        throw Exception('滑板车不存在');
      }

      _scooters[index] = ScooterInfo(
        id: _scooters[index].id,
        model: _scooters[index].model,
        distance: _scooters[index].distance,
        location: 'Updated Location',
        rating: _scooters[index].rating,
        status: _scooters[index].status,
        latLng: newLocation,
        price: _scooters[index].price,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = '更新滑板车位置失败: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('MockScootersProvider 测试', () {
    late MockScootersProvider provider;

    setUp(() {
      provider = MockScootersProvider();
    });

    test('基本属性', () {
      expect(provider.scooters.length, 0);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('fetchScooters 成功', () async {
      await provider.fetchScooters();
      expect(provider.scooters.length, 3);
      expect(provider.scooters.first.model, 'Model A');
      expect(provider.scooters.first.status, 'available');
      expect(provider.scooters.last.model, 'Model C');
      expect(provider.scooters.last.status, 'maintenance');
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('refreshScooters', () async {
      await provider.refreshScooters();
      expect(provider.scooters.length, 3);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('getScooter 成功', () async {
      await provider.fetchScooters();
      final scooter = await provider.getScooter(1);
      expect(scooter?.model, 'Model A');
      expect(scooter?.status, 'available');
      expect(scooter?.price, 10.0);
    });

    test('getScooter 失败 - 不存在的ID', () async {
      await provider.fetchScooters();
      final scooter = await provider.getScooter(999);
      expect(scooter, null);
    });

    test('滑板车属性验证', () async {
      await provider.fetchScooters();
      final scooter = provider.scooters.first;
      
      expect(scooter.id, 1);
      expect(scooter.model, 'Model A');
      expect(scooter.distance, 0.0);
      expect(scooter.location, 'Test Location');
      expect(scooter.rating, 4.5);
      expect(scooter.status, 'available');
      expect(scooter.latLng.latitude, 39.9042);
      expect(scooter.latLng.longitude, 116.4074);
      expect(scooter.price, 10.0);
    });

    test('不同状态的滑板车', () async {
      await provider.fetchScooters();
      
      final availableScooter = provider.scooters.firstWhere((s) => s.status == 'available');
      expect(availableScooter.id, 1);
      expect(availableScooter.model, 'Model A');
      
      final inUseScooter = provider.scooters.firstWhere((s) => s.status == 'in_use');
      expect(inUseScooter.id, 2);
      expect(inUseScooter.model, 'Model B');
      
      final maintenanceScooter = provider.scooters.firstWhere((s) => s.status == 'maintenance');
      expect(maintenanceScooter.id, 3);
      expect(maintenanceScooter.model, 'Model C');
    });

    test('滑板车距离排序', () async {
      await provider.fetchScooters();
      final sortedScooters = List<ScooterInfo>.from(provider.scooters)
        ..sort((a, b) => a.distance.compareTo(b.distance));
      
      expect(sortedScooters[0].distance, 0.0);
      expect(sortedScooters[1].distance, 100.0);
      expect(sortedScooters[2].distance, 200.0);
    });

    test('滑板车评分排序', () async {
      await provider.fetchScooters();
      final sortedScooters = List<ScooterInfo>.from(provider.scooters)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      
      expect(sortedScooters[0].rating, 4.5);
      expect(sortedScooters[1].rating, 4.0);
      expect(sortedScooters[2].rating, 3.5);
    });

    test('滑板车价格验证', () async {
      await provider.fetchScooters();
      
      expect(provider.scooters[0].price, 10.0);
      expect(provider.scooters[1].price, 15.0);
      expect(provider.scooters[2].price, 20.0);
    });

    test('滑板车位置验证', () async {
      await provider.fetchScooters();
      
      expect(provider.scooters[0].latLng.latitude, 39.9042);
      expect(provider.scooters[0].latLng.longitude, 116.4074);
      expect(provider.scooters[1].latLng.latitude, 39.9142);
      expect(provider.scooters[1].latLng.longitude, 116.4174);
      expect(provider.scooters[2].latLng.latitude, 39.9242);
      expect(provider.scooters[2].latLng.longitude, 116.4274);
    });

    test('更新滑板车状态 - 成功', () async {
      await provider.fetchScooters();
      final result = await provider.updateScooterStatus(1, 'in_use');
      
      expect(result, true);
      expect(provider.scooters.first.status, 'in_use');
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('更新滑板车状态 - 失败 - 不存在的ID', () async {
      await provider.fetchScooters();
      final result = await provider.updateScooterStatus(999, 'in_use');
      
      expect(result, false);
      expect(provider.error, isNotNull);
    });

    test('更新滑板车状态 - 失败 - 无效状态', () async {
      await provider.fetchScooters();
      final result = await provider.updateScooterStatus(1, 'invalid_status');
      
      expect(result, false);
      expect(provider.error, isNotNull);
    });

    test('更新滑板车位置 - 成功', () async {
      await provider.fetchScooters();
      final newLocation = LatLng(40.0, 117.0);
      final result = await provider.updateScooterLocation(1, newLocation);
      
      expect(result, true);
      expect(provider.scooters.first.latLng.latitude, 40.0);
      expect(provider.scooters.first.latLng.longitude, 117.0);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('更新滑板车位置 - 失败 - 不存在的ID', () async {
      await provider.fetchScooters();
      final newLocation = LatLng(40.0, 117.0);
      final result = await provider.updateScooterLocation(999, newLocation);
      
      expect(result, false);
      expect(provider.error, isNotNull);
    });

    test('状态变化通知', () async {
      await provider.fetchScooters();
      bool notified = false;
      
      provider.addListener(() {
        notified = true;
      });
      
      await provider.updateScooterStatus(1, 'in_use');
      expect(notified, true);
    });

    test('位置更新通知', () async {
      await provider.fetchScooters();
      bool notified = false;
      
      provider.addListener(() {
        notified = true;
      });
      
      await provider.updateScooterLocation(1, LatLng(40.0, 117.0));
      expect(notified, true);
    });
  });
} 