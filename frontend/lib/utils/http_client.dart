import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../providers/user_provider.dart';

/// HttpClient是一个基于Dio的单例HTTP客户端
/// 使用拦截器处理请求/响应，并集成PrettyDioLogger进行日志美化
class HttpClient {
  // 私有构造函数
  HttpClient._internal() {
    _init();
  }

  // 单例实例
  static final HttpClient _instance = HttpClient._internal();

  // 工厂构造函数返回单例实例
  factory HttpClient() => _instance;

  // Dio实例
  late final Dio dio;
  static const String baseUrl = 'http://119.45.26.22:8222/api/v1';
  // 初始化Dio配置
  void _init() {
    final BaseOptions baseOptions = BaseOptions(
      baseUrl: baseUrl, // 设置你的API基础URL
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    );
    dio = Dio(baseOptions);

    // 添加请求拦截器
    dio.interceptors.add(Interceptor());

    // 添加日志拦截器
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  /// 发送GET请求
  Future<Response> get(
    String endpoint, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.get(
      endpoint,
      queryParameters: data is Map<String, dynamic> ? data : null,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 发送POST请求
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.post(
      endpoint,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 发送PUT请求
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.put(
      endpoint,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 发送DELETE请求
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.delete(
      endpoint,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 发送PATCH请求
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.patch(
      endpoint,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

class Interceptor extends InterceptorsWrapper {
  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (UserProvider().token != null ||
        UserProvider().token!.accessToken.isNotEmpty) {
      // 添加token
      options.headers['Authorization'] =
          'Bearer ${UserProvider().token?.accessToken}';
    }
    return handler.next(options);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    // 在响应返回后做一些处理
    // 检查响应状态码
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      // 成功响应，继续处理
      return handler.next(response);
    } else {
      // 处理非成功状态码
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: '请求失败: ${response.statusCode}',
        ),
      );
    }
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    String errorMessage;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = '网络连接超时';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = '证书验证失败';
        break;
      case DioExceptionType.badResponse:
        errorMessage = '服务器响应异常: ${err.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        errorMessage = '请求已取消';
        break;
      case DioExceptionType.connectionError:
        errorMessage = '网络连接错误';
        break;
      case DioExceptionType.unknown:
      default:
        errorMessage = '未知错误: ${err.message}';
        break;
    }

    // 创建一个新的DioException，包含更详细的错误信息
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
    );

    return handler.next(newError);
  }
}
