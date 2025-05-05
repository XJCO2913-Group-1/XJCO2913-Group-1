import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:easy_scooter/models/llm/conversation.dart';
import 'package:easy_scooter/models/llm/chat_message.dart';
import 'package:easy_scooter/services/llm_service.dart';

class LlmProvider extends ChangeNotifier {
  // 私有构造函数
  LlmProvider._internal();
  // 单例实例
  static final LlmProvider _instance = LlmProvider._internal();
  // 工厂构造函数
  factory LlmProvider() => _instance;

  // 服务实例
  final LlmService _llmService = LlmService();

  // 当前对话的元数据
  Conversation? _currentConversation;

  // 当前对话的消息记录
  List<ChatMessage> _messages = [];

  // Getters
  Conversation? get currentConversation => _currentConversation;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get hasActiveConversation => _currentConversation != null;

  // 创建新对话
  Future<void> createConversation({String title = "新对话"}) async {
    try {
      final conversation = await _llmService.createConversation(title: title);
      _currentConversation = conversation;
      _messages = []; // 清空消息记录，开始新对话
      notifyListeners();
    } catch (e) {
      debugPrint('创建对话失败: $e');
      rethrow;
    }
  }

  // 清除当前对话
  void clearCurrentConversation() {
    _currentConversation = null;
    _messages = [];
    notifyListeners();
  }

  // 添加新消息到当前对话
  void addMessage(ChatMessage message) {
    if (_currentConversation == null) {
      throw Exception('没有活跃的对话，请先创建对话');
    }
    _messages.add(message);
    notifyListeners();
  }

  // 发送用户消息并处理流式响应
  Future<void> sendMessage(String content) async {
    if (_currentConversation == null) {
      throw Exception('没有活跃的对话，请先创建对话');
    }

    try {
      // 添加用户消息
      final userMessage = ChatMessage(
        isUser: true,
        content: content,
        createdAt: DateTime.now(),
        id: DateTime.now().millisecondsSinceEpoch, // 临时ID
      );
      addMessage(userMessage);

      // 创建初始AI响应消息（用于流式更新）
      final aiMessage = ChatMessage(
        isUser: false,
        content: '',
        createdAt: DateTime.now(),
        id: DateTime.now().millisecondsSinceEpoch + 1, // 临时ID
        isStreaming: true,
      );
      addMessage(aiMessage);

      // 用于积累消息内容
      String accumulatedContent = '';

      // 获取流式响应
      final stream = _llmService.sendMessageStream(
        conversationId: _currentConversation!.id,
        message: content,
      );

      debugPrint('开始接收流式响应...');

      // 监听流并更新消息内容
      await for (final chunk in stream) {
        // 记录收到的块
        debugPrint('收到块: "$chunk"');

        // 累积内容
        accumulatedContent += chunk;
        debugPrint(
            '当前累积内容: "${accumulatedContent.length > 50 ? accumulatedContent.substring(0, 50) + '...' : accumulatedContent}"');

        // 更新AI消息内容
        final index = _messages.indexWhere((msg) => msg.id == aiMessage.id);
        if (index != -1) {
          debugPrint('更新消息 #$index');
          _messages[index] = ChatMessage(
            isUser: false,
            content: accumulatedContent,
            createdAt: aiMessage.createdAt,
            id: aiMessage.id,
            isStreaming: true,
          );
          notifyListeners();
        } else {
          debugPrint('未找到消息来更新');
        }
      }

      debugPrint('流已完成，正在更新消息状态...');

      // 流结束，更新状态为非流式
      final index = _messages.indexWhere((msg) => msg.id == aiMessage.id);
      if (index != -1) {
        debugPrint(
            '找到消息，设置isStreaming = false，最终内容: "${accumulatedContent.length > 50 ? accumulatedContent.substring(0, 50) + '...' : accumulatedContent}"');
        _messages[index] = ChatMessage(
          isUser: false,
          content: accumulatedContent,
          createdAt: aiMessage.createdAt,
          id: aiMessage.id,
          isStreaming: false,
        );
        notifyListeners();
      } else {
        debugPrint('未找到需要更新的消息');
      }
    } catch (e) {
      debugPrint('发送消息失败: $e');
      // 移除正在流式传输的消息（如果发生错误）
      _messages.removeWhere((msg) => msg.isStreaming);

      // 添加错误消息
      addMessage(
        ChatMessage(
          isUser: false,
          content: '发送消息失败: $e',
          createdAt: DateTime.now(),
          id: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      rethrow;
    }
  }

  // 取消当前正在进行的流式响应
  void cancelStreaming() {
    // 移除所有正在流式传输的消息
    _messages.removeWhere((message) => message.isStreaming);
    notifyListeners();
  }
}
