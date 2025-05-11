import 'package:flutter_test/flutter_test.dart';
import 'package:easy_scooter/providers/llm_provider.dart';
import 'package:easy_scooter/models/llm/chat_message.dart';
import 'package:easy_scooter/models/llm/conversation.dart';
import 'package:flutter/material.dart';

class MockLlmProvider extends ChangeNotifier implements LlmProvider {
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  @override
  List<Conversation> get conversations => _conversations;
  
  @override
  Conversation? get currentConversation => _currentConversation;
  
  @override
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  
  @override
  bool get hasActiveConversation => _currentConversation != null;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;

  @override
  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = [
        Conversation(
          id: 1,
          title: '测试对话1',
          userId: 1,
          createdAt: DateTime.parse('2024-03-20 10:00:00'),
          updatedAt: DateTime.parse('2024-03-20 10:00:05'),
        ),
        Conversation(
          id: 2,
          title: '测试对话2',
          userId: 1,
          createdAt: DateTime.parse('2024-03-20 11:00:00'),
          updatedAt: DateTime.parse('2024-03-20 11:00:10'),
        ),
      ];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '获取对话记录失败: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  Future<void> createConversation({String title = "新对话"}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newConversation = Conversation(
        id: _conversations.length + 1,
        title: title,
        userId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _conversations.add(newConversation);
      _currentConversation = newConversation;
      _messages = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '创建对话失败: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  void clearCurrentConversation() {
    _currentConversation = null;
    _messages = [];
    notifyListeners();
  }

  @override
  void addMessage(ChatMessage message) {
    if (_currentConversation == null) {
      throw Exception('没有活跃的对话，请先创建对话');
    }
    _messages.add(message);
    notifyListeners();
  }

  @override
  Future<void> sendMessage(String content) async {
    if (_currentConversation == null) {
      throw Exception('没有活跃的对话，请先创建对话');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        isUser: true,
        content: content,
        createdAt: DateTime.now(),
      );
      addMessage(userMessage);

      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        isUser: false,
        content: '这是对 "$content" 的回复',
        createdAt: DateTime.now(),
      );
      addMessage(assistantMessage);

      _currentConversation = Conversation(
        id: _currentConversation!.id,
        title: _currentConversation!.title,
        userId: _currentConversation!.userId,
        createdAt: _currentConversation!.createdAt,
        updatedAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = '发送消息失败: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  void cancelStreaming() {
    _messages.removeWhere((message) => message.isStreaming);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('MockLlmProvider 测试', () {
    late MockLlmProvider provider;

    setUp(() {
      provider = MockLlmProvider();
    });

    test('基本属性', () {
      expect(provider.conversations.length, 0);
      expect(provider.currentConversation, null);
      expect(provider.messages.length, 0);
      expect(provider.hasActiveConversation, false);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('fetchConversations 成功', () async {
      await provider.fetchConversations();
      expect(provider.conversations.length, 2);
      expect(provider.conversations.first.title, '测试对话1');
      expect(provider.conversations.last.title, '测试对话2');
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('createConversation 成功', () async {
      await provider.createConversation(title: '测试对话');
      expect(provider.conversations.length, 1);
      expect(provider.currentConversation?.title, '测试对话');
      expect(provider.messages.length, 0);
      expect(provider.hasActiveConversation, true);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('sendMessage 成功', () async {
      await provider.createConversation();
      await provider.sendMessage('测试消息');
      
      expect(provider.messages.length, 2);
      expect(provider.messages.first.content, '测试消息');
      expect(provider.messages.first.isUser, true);
      expect(provider.messages.last.isUser, false);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('sendMessage 失败 - 没有当前对话', () async {
      expect(() => provider.sendMessage('测试消息'), throwsException);
    });

    test('clearCurrentConversation', () async {
      await provider.createConversation();
      provider.clearCurrentConversation();
      
      expect(provider.currentConversation, null);
      expect(provider.messages.length, 0);
      expect(provider.hasActiveConversation, false);
    });

    test('addMessage', () async {
      await provider.createConversation();
      final message = ChatMessage(
        id: 1,
        isUser: true,
        content: '测试消息',
        createdAt: DateTime.now(),
      );
      provider.addMessage(message);
      
      expect(provider.messages.length, 1);
      expect(provider.messages.first.content, '测试消息');
    });

    test('addMessage 失败 - 没有当前对话', () {
      final message = ChatMessage(
        id: 1,
        isUser: true,
        content: '测试消息',
        createdAt: DateTime.now(),
      );
      expect(() => provider.addMessage(message), throwsException);
    });

    test('cancelStreaming', () async {
      await provider.createConversation();
      final message = ChatMessage(
        id: 1,
        isUser: true,
        content: '测试消息',
        createdAt: DateTime.now(),
        isStreaming: true,
      );
      provider.addMessage(message);
      provider.cancelStreaming();
      
      expect(provider.messages.length, 0);
    });
  });
} 