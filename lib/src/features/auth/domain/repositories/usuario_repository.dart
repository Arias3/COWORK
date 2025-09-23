import '../entities/user_entity.dart';

abstract class UsuarioRepository {
  Future<List<Usuario>> getUsuarios();
  Future<Usuario?> getUsuarioById(int id);
  Future<Usuario?> getUsuarioByEmail(String email);
  Future<int> createUsuario(Usuario usuario);
  Future<void> updateUsuario(Usuario usuario);
  Future<void> deleteUsuario(int id);
  Future<bool> existeEmail(String email);
  Future<Usuario?> login(String email, String password);
  Future<Usuario?> getUsuarioByAuthId(String authUserId);
}