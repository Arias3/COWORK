abstract class RobleAuthLoginRepository {
  Future<Map<String, dynamic>> loginRoble({
    required String email,
    required String password,
  });
}
