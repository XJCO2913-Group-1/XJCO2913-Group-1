import 'package:easy_scooter/utils/http_client.dart';

class PriceService {
  PriceService._internal();
  static final PriceService _instance = PriceService._internal();
  factory PriceService() => _instance;
  final HttpClient _httpClient = HttpClient();
  final endpoint = '/scooter-prices';

  Future<double> getPrice(String model) async {
    final response = await _httpClient.get('$endpoint/$model');

    return response.data['price_per_hour'].toDouble();
  }
}
