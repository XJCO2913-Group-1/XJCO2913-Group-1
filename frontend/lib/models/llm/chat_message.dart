class ChatMessage {
  final bool isUser;
  final String content;
  final DateTime createdAt;
  final int id;
  bool isStreaming;
  ChatMessage({
    required this.isUser,
    required this.content,
    required this.createdAt,
    required this.id,
    this.isStreaming = false,
  });

  // 从Map创建ChatMessage对象
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      isUser: map['is_user'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
