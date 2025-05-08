import 'package:easy_scooter/utils/http/client.dart';

class FeedbackService {
  FeedbackService._internal();

  // 单例实例
  static final FeedbackService _instance = FeedbackService._internal();

  factory FeedbackService() => _instance;

  final HttpClient _httpClient = HttpClient();
  final endpoint = '/feedbacks';

  Future<void> sendFeedback({
    required String feedBackType,
    required String feedBackDetail,
    String priority = 'medium',
    String image = '',
  }) async {
    final requestData = {
      "feedback_type": feedBackType,
      "feedback_detail": feedBackDetail,
      "priority": priority,
      "image": image,
    };

    await _httpClient.post(
      '$endpoint/',
      data: requestData,
    );
  }
}
