import 'package:easy_scooter/services/price_service.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_scooter/models/scooter.dart';
import 'package:easy_scooter/services/scooter_service.dart';

class ScootersProvider extends ChangeNotifier {
  // 私有构造函数
  ScootersProvider._internal();
  // 单例实例
  static final ScootersProvider _instance = ScootersProvider._internal();
  // 工厂构造函数
  factory ScootersProvider() => _instance;

  // 滑板车列表
  List<ScooterInfo> _scooters = [];
  // 加载状态
  bool _isLoading = false;
  // 错误信息
  String? _error;

  // 滑板车服务
  final ScooterService _scooterService = ScooterService();

  // Getters
  List<ScooterInfo> get scooters => _scooters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 获取所有滑板车数据
  Future<void> fetchScooters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 调用ScooterService的获取滑板车方法
      final scooters = await _scooterService.getScooters().then(
        (scooters) async {
          // 获取每个滑板车的价格
          for (int i = 0; i < scooters.length; i++) {
            final price = await PriceService().getPrice(scooters[i].model);

            scooters[i].price = price;
          }
          return scooters;
        },
      );

      _scooters = scooters;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '获取滑板车数据失败: ${e.toString()}';
      notifyListeners();
    }
  }

  /// 获取单个滑板车数据
  Future<ScooterInfo?> getScooter(int id) async {
    try {
      return await _scooterService.getScooter(id);
    } catch (e) {
      _error = '获取滑板车数据失败: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// 刷新滑板车数据
  Future<void> refreshScooters() async {
    await fetchScooters();
  }
}
