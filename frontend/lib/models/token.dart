class Token {
  final String accessToken;
  final String tokenType;

  Token({
    required this.accessToken,
    required this.tokenType,
  });

  factory Token.fromMap(Map<String, dynamic> map) {
    return Token(
      accessToken: map['access_token'] as String,
      tokenType: map['token_type'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }
}
