
import 'package:frontend/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    super.googleId,
    super.name,
    super.email,
    super.profilePicture,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      googleId: json['google_id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profile_picture'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'google_id': googleId,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
