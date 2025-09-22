import '../../domain/repositories/roble_auth_login_repository.dart';
import '../datasources/roble_auth_login_datasource.dart';

class RobleAuthLoginRepositoryImpl implements RobleAuthLoginRepository {
  final RobleAuthLoginDatasource remoteDatasource;

  RobleAuthLoginRepositoryImpl(this.remoteDatasource);

  @override
  Future<Map<String, dynamic>> loginRoble({
    required String email,
    required String password,
  }) {
    return remoteDatasource.login(email: email, password: password);
  }
}
