import 'package:easy_scooter/models/scooter.dart';

import '../utils/http_client.dart';

class ScooterService {
  ScooterService._internal();

  static final ScooterService _instance = ScooterService._internal();

  factory ScooterService() => _instance;

  final HttpClient _httpClient = HttpClient();

  final endPoint = '/scooters';

  Future<List<ScooterInfo>> getScooters() async {
    final response = await _httpClient.get('$endPoint/');
    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> rawData = response.data;
      final List<ScooterInfo> data = rawData
          .map((scooter) => ScooterInfo(
                id: scooter['id'].toString(),
                name: scooter['name'] ?? scooter['model'],
                price: (scooter['price'] ?? 20).toDouble(),
                location: 'Unknown',
                rating: (scooter['rating'] ?? 4.5).toDouble(),
                distance: (scooter['distance'] ?? 10).toDouble(),
              ))
          .toList();
      return data;
    }
    return [];
  }
}
