class UserEntity {
  final int? id;
  final String? googleId;
  final String? name;
  final String? email;
  final String? profilePicture;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    this.id,
    this.googleId,
    this.name,
    this.email,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
  });
}
