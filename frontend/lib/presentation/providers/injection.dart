import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/impl/auth.dart';
import 'package:frontend/domain/repositories/auth.dart';
import 'package:frontend/infrastructure/api/auth_api.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(authApiProvider);
  return AuthImpl(api);
});
