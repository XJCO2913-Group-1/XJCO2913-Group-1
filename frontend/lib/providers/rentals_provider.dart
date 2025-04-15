import 'package:flutter/foundation.dart';
import 'package:easy_scooter/models/rental.dart';
import 'package:easy_scooter/services/rental_service.dart';

class RentalsProvider extends ChangeNotifier {
  // 私有构造函数
  RentalsProvider._internal();
  // 单例实例
  static final RentalsProvider _instance = RentalsProvider._internal();
  // 工厂构造函数
  factory RentalsProvider() => _instance;

  // 租赁列表
  List<Rental> _rentals = [];
  // 加载状态
  bool _isLoading = false;
  // 错误信息
  String? _error;

  // 租赁服务
  final RentalService _rentalService = RentalService();

  // Getters
  List<Rental> get rentals => _rentals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 获取用户的所有租赁记录
  Future<void> fetchRentals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 调用RentalService的获取租赁记录方法
      final rentals = await _rentalService.getRentals();
      _rentals = rentals;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '获取租赁记录失败: ${e.toString()}';
      notifyListeners();
    }
  }

  /// 创建新的租赁记录
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
      // 调用RentalService的创建租赁记录方法
      final success = await _rentalService.createRental(
        scooterId: scooterId,
        rentalPeriod: rentalPeriod,
        userId: userId,
        startTime: startTime,
        endTime: endTime,
        status: status,
        cost: cost,
      );

      _isLoading = false;

      if (success) {
        // 如果创建成功，刷新租赁列表
        await fetchRentals();
      } else {
        _error = '创建租赁记录失败';
        notifyListeners();
      }

      return success;
    } catch (e) {
      _isLoading = false;
      _error = '创建租赁记录失败: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _rentals = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// 删除租赁记录
  Future<bool> deleteRental(int rentalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 调用RentalService的删除租赁记录方法
      final success = await _rentalService.deleteRental(rentalId);

      _isLoading = false;

      if (success) {
        // 如果删除成功，刷新租赁列表
        await fetchRentals();
      } else {
        _error = '删除租赁记录失败';
        notifyListeners();
      }

      return success;
    } catch (e) {
      _isLoading = false;
      _error = '删除租赁记录失败: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
