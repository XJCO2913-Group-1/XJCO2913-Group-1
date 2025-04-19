import 'package:dio/dio.dart';

import '../utils/http_client.dart';
import '../models/token.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final HttpClient _httpClient = HttpClient();

  final endpoint = '/auth';

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

    final response = await _httpClient.post(
      '$endpoint/login',
      data: requestData,
      options: Options(
        contentType: Headers
            .formUrlEncodedContentType, // 设置为application/x-www-form-urlencoded
      ),
    );
    return Token.fromMap(response.data);
  }

  Future<void> passwordReset({
    required String email,
  }) async {
    final requestData = {
      'email': email,
    };
    try {
      await _httpClient.post(
        '$endpoint/password-reset-request',
        data: requestData,
      );
    } catch (e) {
      print(e);
    }
  }
}
