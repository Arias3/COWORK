import '../repositories/roble_auth_login_repository.dart';

class RobleAuthLoginUseCase {
  final RobleAuthLoginRepository repository;

  RobleAuthLoginUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String email,
    required String password,
  }) {
    return repository.loginRoble(email: email, password: password);
  }
}
