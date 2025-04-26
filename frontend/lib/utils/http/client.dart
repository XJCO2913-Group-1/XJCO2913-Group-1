import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'constants.dart';
import 'interceptors.dart';

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
  final HttpInterceptor interceptor = HttpInterceptor();

  // 初始化Dio配置
  void _init() {
    final BaseOptions baseOptions = BaseOptions(
      baseUrl: HttpConstants.baseUrl,
      connectTimeout: Duration(seconds: HttpConstants.connectTimeout),
      receiveTimeout: Duration(seconds: HttpConstants.receiveTimeout),
      headers: HttpConstants.defaultHeaders,
      responseType: ResponseType.json,
    );
    dio = Dio(baseOptions);

    // 添加请求拦截器
    dio.interceptors.add(interceptor);

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

  /// 发送流式GET请求，返回一个Stream
  Stream<Response<ResponseBody>> getStream(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    options = options ?? Options();
    options.responseType = ResponseType.stream;

    return Stream.fromFuture(
      dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// 发送流式POST请求，返回一个Stream
  Stream<Response<ResponseBody>> postStream(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    options = options ?? Options();
    options.responseType = ResponseType.stream;

    return Stream.fromFuture(
      dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }
}
