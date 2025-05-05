// ignore_for_file: file_names
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_scooter/models/llm/conversation.dart';
import 'package:easy_scooter/utils/http/client.dart';
import 'package:flutter/foundation.dart';

class LlmService {
  LlmService._internal();

  static final LlmService _instance = LlmService._internal();

  factory LlmService() => _instance;

  final HttpClient _httpClient = HttpClient();
  final endpoint = '/llm/api/conversations';

  Future<Conversation> createConversation({
    String title = "新对话",
  }) async {
    final response = await _httpClient.post(endpoint, data: {
      'title': title,
    });
    return Conversation.fromMap(response.data);
  }

  /// 发送消息并获取流式响应
  Stream<String> sendMessageStream({
    required int conversationId,
    required String message,
  }) {
    // 创建一个控制器来管理流
    final streamController = StreamController<String>();

    // 发送请求获取流式响应
    _httpClient.postStream('$endpoint/$conversationId/messages', data: {
      'content': message,
      'is_user': true,
      'conversation_id': conversationId,
    }).listen((response) {
      // 处理响应流
      final stream = response.data as ResponseBody;

      // 转换字节流为字符串流
      stream.stream.listen(
        (data) {
          try {
            // 解码字节流为字符串
            final String text = utf8.decode(data);

            // 处理后端特定的格式: "data: data:{json}"
            final lines = text.split('\n');

            for (var line in lines) {
              if (line.isEmpty) continue;

              // 检查行是否包含JSON数据
              if (line.startsWith('data: data:')) {
                // 提取JSON部分 (去掉 "data: data:" 前缀)
                final jsonPart = line.substring(11);

                try {
                  final Map<String, dynamic> parsed = jsonDecode(jsonPart);
                  if (parsed.containsKey('answer')) {
                    // 向流中添加answer字段
                    streamController.add(parsed['answer']);
                  }
                } catch (e) {
                  debugPrint('解析JSON失败: $e, 原始数据: $jsonPart');
                }
              }
              // 不需要显式检查结束标记，当流结束时会自动触发onDone回调
            }
          } catch (e) {
            debugPrint('处理数据流出错: $e');
            streamController.addError('处理数据流出错: $e');
          }
        },
        onDone: () {
          // 流自然结束，没有明确的结束标记
          debugPrint('流数据接收完成');
          streamController.close();
        },
        onError: (e) {
          debugPrint('流处理错误: $e');
          streamController.addError('流处理错误: $e');
          streamController.close();
        },
      );
    }, onError: (e) {
      debugPrint('请求错误: $e');
      streamController.addError('请求错误: $e');
      streamController.close();
    });

    return streamController.stream;
  }
}
