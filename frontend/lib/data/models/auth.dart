
import 'package:frontend/domain/entities/auth.dart';

class AuthModel extends AuthEntity{

  AuthModel({
    required super.userId,
    required super.accessToken,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      userId: json['user_id'].toString(),
      accessToken: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'access_token': accessToken,
    };
  }

  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId.toString(),
      accessToken: accessToken,
    );
  }
}