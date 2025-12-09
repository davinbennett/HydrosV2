
import '../repositories/profile.dart';

class ProfileUsecase {
  final ProfileRepository repository;

  ProfileUsecase(this.repository);

  Future<Map<String, dynamic>> getProfileUsecase(String userId) async {
    return await repository.getProfileImpl(userId);
  }

}