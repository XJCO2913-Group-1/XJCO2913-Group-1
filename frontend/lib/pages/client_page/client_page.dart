// 先做状态管理 再提取组件
import 'package:flutter/material.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime time;

  Message({required this.text, required this.isUser, required this.time});
}

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [
    Message(
      text: 'Hello! Welcome to the shared e-bike service. How may I help you?',
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Message(
      text: 'I would like to know how to rent an e-bike',
      isUser: true,
      time: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    Message(
      text:
          'You can find nearby e-bikes on the map in the home page, then go to the scan page to scan the QR code on the vehicle to rent it.',
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();

    setState(() {
      _messageController.clear();
      _messages.add(
        Message(
          text: messageText,
          isUser: true,
          time: DateTime.now(),
        ),
      );
    });

    // 滚动到底部
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // 模拟客服回复
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          Message(
            text:
                'Thank you for your inquiry. Our customer service team will respond shortly.',
            isUser: false,
            time: DateTime.now(),
          ),
        );
      });

      // 再次滚动到底部
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
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
                  color: Colors.grey.withValues(
                    alpha: 0.3,
                  ),
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
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withValues(
                              alpha: 0.7,
                            )
                          : Colors.black54,
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
