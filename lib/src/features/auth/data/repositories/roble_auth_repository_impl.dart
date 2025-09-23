import '../../domain/repositories/roble_auth_repository.dart';
import '../datasources/roble_auth_register_datasource.dart';

class RobleAuthRepositoryImpl implements RobleAuthRepository {
  final RobleAuthDatasource remoteDatasource;

  RobleAuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<bool> registerRoble({
    required String email,
    required String password,
    required String name,
  }) {
    return remoteDatasource.register(
      email: email,
      password: password,
      name: name,
    );
  }
}