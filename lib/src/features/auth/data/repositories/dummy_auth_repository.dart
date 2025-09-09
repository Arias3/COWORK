import '../../domain/models/authentication_user.dart';
import '../../domain/repositories/i_auth_repository.dart';

class DummyAuthRepository implements IAuthRepository {
  final String _dummyEmail = "admin";
  final String _dummyPassword = "admin";
  bool _logged = false;

  @override
  Future<bool> login(AuthenticationUser user) async {
    if (user.email == _dummyEmail && user.password == _dummyPassword) {
      _logged = true;
      return true;
    }
    return false;
  }

  @override
  Future<bool> signUp(AuthenticationUser user) async => true;

  @override
  Future<bool> validate(String email, String code) async => true;

  @override
  Future<bool> logOut() async {
    _logged = false;
    return true;
  }

  @override
  Future<bool> validateToken() async => _logged;

  @override
  Future<void> forgotPassword(String email) async {}
}
