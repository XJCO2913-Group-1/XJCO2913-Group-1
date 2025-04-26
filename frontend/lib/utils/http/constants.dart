/// HTTP客户端使用的常量
class HttpConstants {
  /// API基础URL
  static const String baseUrl = 'http://119.45.26.22:8222/api/v1';

  /// 连接超时时间（秒）
  static const int connectTimeout = 15;

  /// 接收超时时间（秒）
  static const int receiveTimeout = 15;

  /// 默认请求头
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
