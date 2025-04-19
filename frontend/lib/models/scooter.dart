// 滑板车信息数据模型
import 'package:latlong2/latlong.dart';

class ScooterInfo {
  final int id;
  final String model;
  final double distance;
  final String location;
  final double rating;
  double? price;
  final String status;
  final LatLng latLng;

  ScooterInfo({
    required this.id,
    required this.model,
    required this.distance,
    required this.location,
    required this.rating,
    required this.status,
    required this.latLng,
    this.price,
  });

  void setPrice(double price) {
    // 设置价格
    price = price;
  }
}
