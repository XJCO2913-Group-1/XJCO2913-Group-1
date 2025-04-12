import '../utils/http_client.dart';

class FeedbackService {
  FeedbackService._internal();

  // 单例实例
  static final FeedbackService _instance = FeedbackService._internal();

  factory FeedbackService() => _instance;

  final HttpClient _httpClient = HttpClient();
  final endpoint = '/feedbacks';

  Future<bool> sendFeedback({
    required String feedBackType,
    required String feedBackDetail,
  }) async {
    final requestData = {
      "feedback_type": feedBackType,
      "feedback_detail": feedBackDetail,
      "priority": "medium"
    };

    try {
      final response = await _httpClient.post(
        '$endpoint/',
        data: requestData,
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
