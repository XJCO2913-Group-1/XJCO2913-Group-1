class Conversation {
  final String title;
  final int id;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.title,
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // 从Map创建Conversation对象
  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      title: map['title'],
      id: map['id'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
