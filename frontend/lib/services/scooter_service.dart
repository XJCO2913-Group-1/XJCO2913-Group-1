import 'package:easy_scooter/models/scooter.dart';

import '../utils/http_client.dart';

class ScooterService {
  ScooterService._internal();

  static final ScooterService _instance = ScooterService._internal();

  factory ScooterService() => _instance;

  final HttpClient _httpClient = HttpClient();

  final endPoint = '/scooters';
  ScooterInfo _parse(
    dynamic data,
  ) {
    return ScooterInfo(
      id: data['id'],
      name: data['name'] ?? data['model'],
      price: (data['price'] ?? 20).toDouble(),
      location: 'Unknown',
      rating: (data['rating'] ?? 4.5).toDouble(),
      status: data['status'] ?? 'null',
      distance: (data['distance'] ?? 10).toDouble(),
    );
  }

  Future<List<ScooterInfo>> getScooters() async {
    final response = await _httpClient.get('$endPoint/');
    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic> rawData = response.data;
      final List<ScooterInfo> data =
          rawData.map((scooter) => _parse(scooter)).toList();
      return data;
    }
    return [];
  }

  Future<ScooterInfo> getScooter(int id) async {
    final response = await _httpClient.get('$endPoint/$id');
    if (response.statusCode == 200 && response.data != null) {
      return _parse(response.data);
    }
    return _parse({});
  }

  Future<void> updateScooters() async {
    final scooters = await getScooters();
    for (final scooter in scooters) {
      await _httpClient.put('$endPoint/${scooter.id}', data: {
        "model": scooter.name,
        "status": "available",
      });
    }
  }
}
