import '../models/user.dart';
import '../utils/http_client.dart';

class UserService {
  UserService._internal();

  // 单例实例
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  final HttpClient _httpClient = HttpClient();

  final endpoint = '/users';

  Future<User> createUser({
    required String email,
    required bool isActive,
    required String name,
    required String password,
  }) async {
    // 发送请求并直接处理正常响应情况
    // 错误处理已经在HttpClient的拦截器中统一处理
    final response = await _httpClient.post(
      "$endpoint/",
      data: {
        'email': email,
        'is_active': isActive,
        'name': name,
        'password': password,
      },
    );
    return User.fromMap(response.data);
  }

  Future<User> getCurrentUser() async {
    final response = await _httpClient.get(
      "$endpoint/me",
    );
    return User.fromMap(response.data);
  }

  Future<User> getUser() async {
    final response = await _httpClient.get(
      "$endpoint/me",
    );
    return User.fromMap(response.data);
  }

  Future<User> updateUser({
    required int id,
    int? age,
    String? school,
  }) async {
    final response = await _httpClient.put(
      "$endpoint/$id",
      data: {
        'school': school,
        'age': age,
      },
    );
    return User.fromMap(response.data);
  }
}
