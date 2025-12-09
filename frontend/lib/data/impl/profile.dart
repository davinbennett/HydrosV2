import '../../domain/repositories/profile.dart';
import '../../infrastructure/api/profile_api.dart';

class ProfileImpl implements ProfileRepository {
  final ProfileApi api;
  ProfileImpl({required this.api});

  @override
  Future<Map<String, dynamic>> getProfileImpl(String userId) {
    return api.getProfileApi(userId);
  }
}
