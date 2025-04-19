class User {
  final int id;
  final String name;
  final String email;

  final String? avatar;
  String? school;
  int? age;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.school,
    this.age,
  });

  // 从Map创建User对象
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      school: map['school'],
      age: map['age'],
      avatar: map['avatar'],
    );
  }

  // 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (school != null) 'school': school,
      if (age != null) 'age': age,
      if (avatar != null) 'avatar': avatar,
    };
  }
}
