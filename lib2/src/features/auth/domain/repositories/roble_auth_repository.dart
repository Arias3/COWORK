abstract class RobleAuthRepository {
  Future<bool> registerRoble({
    required String email,
    required String password,
    required String name,
  });
}
