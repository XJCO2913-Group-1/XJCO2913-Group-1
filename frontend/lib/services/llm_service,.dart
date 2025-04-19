import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_scooter/models/llm/conversation.dart';
import 'package:easy_scooter/utils/http_client.dart';
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
            // 对于SSE(Server-Sent Events)格式，通常每行是一个JSON
            final String text = utf8.decode(data);
            final lines = text
                .split('\n')
                .where((line) => line.isNotEmpty && line.startsWith('data: '));

            for (var line in lines) {
              // 移除"data: "前缀
              final jsonData = line.substring(6);
              if (jsonData.trim() == '[DONE]') {
                // 流结束标记
                continue;
              }

              try {
                final Map<String, dynamic> parsed = jsonDecode(jsonData);
                if (parsed.containsKey('answer')) {
                  streamController.add(parsed['answer']);
                }
              } catch (e) {
                debugPrint('解析JSON失败: $e, 原始数据: $jsonData');
              }
            }
          } catch (e) {
            streamController.addError('处理数据流出错: $e');
          }
        },
        onDone: () {
          streamController.close();
        },
        onError: (e) {
          streamController.addError('流处理错误: $e');
          streamController.close();
        },
      );
    }, onError: (e) {
      streamController.addError('请求错误: $e');
      streamController.close();
    });

    return streamController.stream;
  }
}
