import 'package:frontend/domain/entities/user.dart';

class LoginModel extends UserEntity {
  const LoginModel({required int userId, required String accessToken})
    : super(
        id: userId,
        googleId: accessToken, // kita gunakan field ini untuk menyimpan token
      );

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return LoginModel(
      userId: data['user_id'],
      accessToken: data['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': id, 'access_token': googleId};
  }
}
