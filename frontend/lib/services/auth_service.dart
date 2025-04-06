import 'package:dio/dio.dart';

import '../utils/http_client.dart';
import '../models/token.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final HttpClient _httpClient = HttpClient();

  static const String _authEndpoint = '/auth';

  Future<Token> login({
    required String email,
    required String password,
  }) async {
    final requestData = {
      'grant_type': 'password',
      'username': email,
      'password': password,
      'scope': '',
      'client_id': '',
      'client_secret': '',
    };
    // print('Request Data: $requestData');
    try {
      final response = await _httpClient.post(
        '$_authEndpoint/login',
        data: requestData,
        options: Options(
          contentType: Headers
              .formUrlEncodedContentType, // 设置为application/x-www-form-urlencoded
        ),
      );
      return Token.fromMap(response.data);
    } catch (e) {
      print(e);
      return Token.fromMap({});
    }
  }
}
