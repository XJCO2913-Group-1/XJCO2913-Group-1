import 'package:easy_scooter/models/bound.dart';
import 'package:easy_scooter/utils/http/client.dart';

class NoParkingZonesService {
  NoParkingZonesService._internal();

  static final NoParkingZonesService _instance =
      NoParkingZonesService._internal();

  factory NoParkingZonesService() => _instance;

  final HttpClient _httpClient = HttpClient();

  final endpoint = '/no-parking-zones';

  Future<List<Bound>> getNoParkingZones() async {
    final response = await _httpClient.get('$endpoint/');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => Bound.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
