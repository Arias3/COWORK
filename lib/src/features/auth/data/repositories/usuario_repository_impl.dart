import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../../../../core/data/database/hive_helper.dart';




class UsuarioRepositoryImpl implements UsuarioRepository {
  @override
  Future<List<Usuario>> getUsuarios() async {
    final box = HiveHelper.usuariosBoxInstance;
    return box.values.toList();
  }

  @override
  Future<Usuario?> getUsuarioById(int id) async {
    final box = HiveHelper.usuariosBoxInstance;
    return box.get(id);
  }

  @override
  Future<Usuario?> getUsuarioByEmail(String email) async {
    final box = HiveHelper.usuariosBoxInstance;
    try {
      return box.values.firstWhere(
        (usuario) => usuario.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

@override
Future<int> createUsuario(Usuario usuario) async {
  final box = HiveHelper.usuariosBoxInstance;
  
  // Generar ID si no lo tiene
  if (usuario.id == null) {
    final usuarios = box.values.toList();
    final nuevoId = usuarios.isEmpty 
      ? 1 
      : usuarios.map((u) => u.id!).reduce((a, b) => a > b ? a : b) + 1;
    usuario.id = nuevoId;
  }

  await box.put(usuario.id!, usuario);
  await box.flush();
  return usuario.id!;
}

@override
Future<Usuario?> getUsuarioByAuthId(String authUserId) async {
  final box = HiveHelper.usuariosBoxInstance;
  try {
    return box.values.firstWhere(
      (usuario) => usuario.authUserId == authUserId,
    );
  } catch (e) {
    return null;
  }
}

  @override
  Future<void> updateUsuario(Usuario usuario) async {
    final box = HiveHelper.usuariosBoxInstance;
    await box.put(usuario.id, usuario);
    await box.flush();
  }

  @override
  Future<void> deleteUsuario(int id) async {
    final box = HiveHelper.usuariosBoxInstance;
    await box.delete(id);
    await box.flush();
  }

  @override
  Future<bool> existeEmail(String email) async {
    final box = HiveHelper.usuariosBoxInstance;
    return box.values.any(
      (usuario) => usuario.email.toLowerCase() == email.toLowerCase()
    );
  }

  @override
  Future<Usuario?> login(String email, String password) async {
    final box = HiveHelper.usuariosBoxInstance;
    try {
      return box.values.firstWhere(
        (usuario) => 
          usuario.email.toLowerCase() == email.toLowerCase() && 
          usuario.password == password
      );
    } catch (e) {
      return null;
    }
  }
}