import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecase/profile.dart';

class ProfileController {
  final ProfileUsecase profileUsecase;
  final Ref ref;

  ProfileController({required this.profileUsecase, required this.ref});

  Future<Map<String, dynamic>> getProfileController(
    String userId
  ) async {
    final data = await profileUsecase.getProfileUsecase(
      userId
    );

    return data;
  }
}
