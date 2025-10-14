class AuthEntity {
  final String userId;
  final String accessToken;

  AuthEntity({
    required this.userId,
    required this.accessToken,
  });

  AuthEntity copyWith({String? userId, String? accessToken}) {
    return AuthEntity(
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}
