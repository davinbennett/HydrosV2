
class LoginModel {
  final int userId;
  final String accessToken;

  const LoginModel({
    required this.userId,
    required this.accessToken,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      userId: json['user_id'],
      accessToken: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'access_token': accessToken,
    };
  }
}

class SignupModel {
  final int userId;
  final String accessToken;

  const SignupModel({
    required this.userId,
    required this.accessToken,
  });

  factory SignupModel.fromJson(Map<String, dynamic> json) {
    return SignupModel(
      userId: json['user_id'],
      accessToken: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'access_token': accessToken,
    };
  }
}
