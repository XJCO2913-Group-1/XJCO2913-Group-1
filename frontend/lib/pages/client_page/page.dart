import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_scooter/models/llm/chat_message.dart';
import 'package:easy_scooter/providers/llm_provider.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isStreaming;

  Message({
    required this.text,
    required this.isUser,
    required this.time,
    this.isStreaming = false,
  });

  // Convert from ChatMessage
  factory Message.fromChatMessage(ChatMessage chatMessage) {
    return Message(
      text: chatMessage.content,
      isUser: chatMessage.isUser,
      time: chatMessage.createdAt,
      isStreaming: chatMessage.isStreaming,
    );
  }
}

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late LlmProvider _llmProvider;
  bool _isInitialized = false;

  // 初始化对话消息
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _initLlmProvider();
  }

  // 初始化LLM提供者
  Future<void> _initLlmProvider() async {
    _llmProvider = LlmProvider();

    // 添加监听器，当LlmProvider有更新时刷新UI
    _llmProvider.addListener(_syncMessagesFromProvider);

    // 如果没有活跃对话，创建一个新对话
    if (!_llmProvider.hasActiveConversation) {
      try {
        await _llmProvider.createConversation(title: "客服对话");

        // 添加欢迎消息
        setState(() {
          _messages.add(
            Message(
              text:
                  'Hello! Welcome to the shared e-bike service. How may I help you?',
              isUser: false,
              time: DateTime.now(),
            ),
          );
        });

        _isInitialized = true;
      } catch (e) {
        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize chat: $e')),
        );
      }
    } else {
      // 加载现有对话
      _syncMessagesFromProvider();
      _isInitialized = true;
    }
  }

  // 从Provider同步消息到UI
  void _syncMessagesFromProvider() {
    final providerMessages = _llmProvider.messages;
    debugPrint('同步消息: 收到 ${providerMessages.length} 条消息');
    if (providerMessages.isNotEmpty) {
      for (var msg in providerMessages) {
        debugPrint(
            '消息: ${msg.isUser ? '用户' : 'AI'}, 内容: ${msg.content.substring(0, msg.content.length > 20 ? 20 : msg.content.length)}${msg.content.length > 20 ? '...' : ''}, isStreaming: ${msg.isStreaming}');
      }
    }

    setState(() {
      _messages.clear();
      _messages.addAll(providerMessages
          .map((chatMsg) => Message.fromChatMessage(chatMsg))
          .toList());
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    // 移除监听器
    _llmProvider.removeListener(_syncMessagesFromProvider);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动到底部
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 发送消息方法
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat is initializing, please wait...')),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // 添加用户消息到UI
    setState(() {
      _messages.add(
        Message(text: messageText, isUser: true, time: DateTime.now()),
      );
    });
    _scrollToBottom();

    try {
      // 发送消息到LLM服务并开始流式更新
      await _llmProvider.sendMessage(messageText);

      // 将LLM的响应同步到UI
      setState(() {
        // 确保UI中的消息与LlmProvider中的消息一致
        _messages.clear();
        _messages.addAll(_llmProvider.messages
            .map((chatMsg) => Message.fromChatMessage(chatMsg))
            .toList());
      });
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling customer service...')),
            );
            // TODO: Implement phone call functionality
          },
        ),
        title: const Text('Customer Service'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Switched to AI service mode')),
              );
              // TODO: Implement AI service functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表区域
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, theme);
              },
            ),
          ),
          // 底部输入区域
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(76),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              children: [
                // 附件按钮
                Material(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24.0),
                  child: InkWell(
                    onTap: () {
                      // TODO: 实现附件功能
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Attachment feature coming soon')),
                      );
                    },
                    borderRadius: BorderRadius.circular(24.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      child: const Icon(
                        Icons.attach_file,
                        color: Colors.black54,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                // 输入框
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                // 发送按钮
                const SizedBox(width: 8.0),
                Material(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(24.0),
                  child: InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(24.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, ThemeData theme) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // 客服头像
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              radius: 16,
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8.0),
          ],
          // 消息气泡
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: isUser ? theme.colorScheme.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(18.0).copyWith(
                  bottomLeft: isUser ? null : const Radius.circular(0),
                  bottomRight: isUser ? const Radius.circular(0) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Always show the text content
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16.0,
                    ),
                  ),

                  // Show typing indicator when streaming
                  if (message.isStreaming) ...[
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Typing',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        SizedBox(
                          width: 8.0,
                          height: 8.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 4.0),
                  Text(
                    '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color:
                          isUser ? Colors.white.withAlpha(178) : Colors.black54,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            // 用户头像
            const SizedBox(width: 8.0),
            CircleAvatar(
              backgroundColor: Colors.orange,
              radius: 16,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
