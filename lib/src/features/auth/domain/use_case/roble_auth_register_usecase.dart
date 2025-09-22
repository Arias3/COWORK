import '../repositories/roble_auth_repository.dart';

class RobleAuthRegisterUseCase {
  final RobleAuthRepository repository;

  RobleAuthRegisterUseCase(this.repository);

  Future<bool> call({
    required String email,
    required String password,
    required String name,
  }) {
    return repository.registerRoble(
      email: email,
      password: password,
      name: name,
    );
  }
}
