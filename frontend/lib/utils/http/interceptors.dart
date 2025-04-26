import 'package:dio/dio.dart';
import '../../providers/user_provider.dart';

/// HTTP请求拦截器，处理请求/响应/错误
class HttpInterceptor extends InterceptorsWrapper {
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
        final details = err.response?.data['detail'];

        final errorMessages = details is List
            ? details.map((e) => e['msg'] + '\n').toList()
            : details.toString();

        errorMessage = '$errorMessages';
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
