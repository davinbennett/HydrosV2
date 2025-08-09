class UserEntity {
  final int? id;
  final String? googleId;
  final String? username;
  final String? email;
  final String? profilePicture;
  final String? password;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    this.id,
    this.googleId,
    this.username,
    this.email,
    this.profilePicture,
    this.password,
    this.createdAt,
    this.updatedAt,
  });
}
