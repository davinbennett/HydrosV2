
import 'package:frontend/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    super.googleId,
    super.username,
    super.email,
    super.profilePicture,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      googleId: json['google_id'],
      username: json['name'],
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
      'name': username,
      'email': email,
      'profile_picture': profilePicture,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserEntity toEntity() => UserEntity(
    id: id,
    googleId: googleId,
    username: username,
    email: email,
    profilePicture: profilePicture,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
