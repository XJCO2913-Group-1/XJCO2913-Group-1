import 'package:easy_scooter/models/discount.dart';
import 'package:easy_scooter/models/new_rental.dart';
import 'package:easy_scooter/models/rental.dart';
import 'package:easy_scooter/providers/user_provider.dart';
import 'package:easy_scooter/utils/http/client.dart';

import "./scooter_service.dart";

class RentalService {
  RentalService._internal();

  // 单例实例
  static final RentalService _instance = RentalService._internal();

  factory RentalService() => _instance;

  final HttpClient _httpClient = HttpClient();
  final endpoint = '/rentals';

  Future<bool> createRental({
    required int scooterId,
    required String rentalPeriod,
    int? userId,
    String? startTime,
    String? endTime,
    String? status,
    double? cost,
  }) async {
    final response = await _httpClient.post('$endpoint/', data: {
      'scooter_id': scooterId,
      'rental_period': rentalPeriod,
      'user_id': userId,
      'start_time': startTime,
      "end_time": endTime,
      'status': status,
      'cost': cost,
    });
    return response.statusCode == 201;
  }

  Future<List<Rental>> getRentals() async {
    final response = await _httpClient.get('$endpoint/');
    if (response.statusCode == 200) {
      final List<dynamic> rawData = response.data;
      final List<dynamic> filteredData = rawData
          .where((item) => item['user_id'] == UserProvider().user?.id)
          .map((item) => {
                "scooter_id": item["scooter_id"],
                "start_time": item["start_time"],
                "end_time": item["end_time"],
                "status": item["status"],
                "cost": item["cost"],
                "rental_period": item["rental_period"],
                "id": item["id"],
              })
          .toList();

      List<Future<Rental>> rentalFutures =
          filteredData.map<Future<Rental>>((item) async {
        final scooter = await ScooterService().getScooter(item['scooter_id']);
        print(filteredData);

        return Rental(
          id: item['id'],
          scooterId: item['scooter_id'],
          scooterName: scooter.model,
          startTime: DateTime.parse(item['start_time']),
          endTime: DateTime.parse(item['end_time']),
          rentalPeriod: item['rental_period'] ?? "1hr",
          cost: item['cost']?.toDouble() ?? 0.0,
          location: scooter.location,
          status: item['status'] ?? "未知状态",
        );
      }).toList();

      // 等待所有Future完成
      return await Future.wait(rentalFutures);
    }
    return [];
  }

  Future<bool> deleteRental(int rentalId) async {
    final response = await _httpClient.delete('$endpoint/$rentalId');
    ScooterService().updateScooter(response.data['scooter_id']);
    return response.statusCode == 200;
  }

  Future<void> updateRentalState(int id, String state) async {
    await _httpClient.patch('$endpoint/$id', data: {
      'status': state,
    });
  }

  Future<void> updateRental(int id, NewRental newRental) async {
    await _httpClient.patch('$endpoint/$id', data: {
      'start_time': newRental.startTime,
      'end_time': newRental.endTime,
      // 'rental_period': newRental.rentalPeriod,
      'cost': newRental.cost,
    });
  }

  Discount mapToDiscount(Map<String, dynamic> data) {
    return Discount(
      oneHourDiscount: data['period_discounts']['1hr']?.toDouble() ?? 1.0,
      fourHoursDiscount: data['period_discounts']['4hrs']?.toDouble() ?? 1.0,
      oneDayDiscount: data['period_discounts']['1day']?.toDouble() ?? 1.0,
      oneWeekDiscount: data['period_discounts']['1week']?.toDouble() ?? 1.0,
      studentDiscount: data['student_discount']?.toDouble() ?? 1.0,
      oldDiscount: data['old_discount']?.toDouble() ?? 1.0,
    );
  }

  Future<Discount> getRentalConfig() async {
    final response = await _httpClient.get('/rental-configs/active');
    return mapToDiscount(response.data);
  }
}
