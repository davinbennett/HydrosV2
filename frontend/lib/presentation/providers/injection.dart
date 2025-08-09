import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/impl/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';
import 'package:frontend/infrastructure/api/auth_api.dart';
import 'package:frontend/infrastructure/google_signin/auth.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi();
});

final firebaseServiceProvider = Provider<GoogleSigninAuthService>((ref) {
  return GoogleSigninAuthService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(authApiProvider);
  final firebase = ref.read(firebaseServiceProvider);
  return AuthImpl(api: api, firebaseService: firebase);
});
