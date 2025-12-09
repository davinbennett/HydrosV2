abstract class ProfileRepository {
  Future<Map<String, dynamic>> getProfileImpl(String userId);
}