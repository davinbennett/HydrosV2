// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frontend/infrastructure/local/secure_storage.dart';
// import 'package:frontend/presentation/providers/auth_provider.dart';

// class ProfileController extends StateNotifier<AuthStatus>{
//   ProfileController() : super(AuthStatus.authenticated);
  
//   Future<void> logout() async {
//     await SecureStorage.clearAll();
//     state = AuthStatus.unauthenticated;
//   }
// }