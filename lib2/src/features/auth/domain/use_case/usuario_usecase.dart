import '../entities/user_entity.dart';
import '../repositories/usuario_repository.dart';

class UsuarioUseCase {
  final UsuarioRepository _repository;

  UsuarioUseCase(this._repository);

  Future<List<Usuario>> getUsuarios() => _repository.getUsuarios();
  Future<Usuario?> getUsuarioById(int id) => _repository.getUsuarioById(id);
  Future<Usuario?> getUsuarioByEmail(String email) =>
      _repository.getUsuarioByEmail(email);

  Future<int> createUsuario({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    bool fromExternalAuth = false, // Nuevo parámetro
  }) async {
    // Validaciones existentes
    if (nombre.trim().isEmpty) throw Exception('El nombre es obligatorio');
    if (email.trim().isEmpty) throw Exception('El email es obligatorio');

    // Solo validar contraseña si no es de autenticación externa
    if (!fromExternalAuth && password.trim().isEmpty) {
      throw Exception('La contraseña es obligatoria');
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw Exception('Email no válido');
    }

    // Verificar si el email ya existe
    if (await _repository.existeEmail(email)) {
      throw Exception('Este email ya está registrado');
    }

    // Generar nuevo ID único
    final usuarios = await _repository.getUsuarios();
    final nuevoId = usuarios.isEmpty
        ? 1
        : usuarios.map((u) => u.id!).reduce((a, b) => a > b ? a : b) + 1;

    final usuario = Usuario(
      id: nuevoId,
      nombre: nombre.trim(),
      email: email.trim().toLowerCase(),
      password: fromExternalAuth
          ? '[ROBLE_AUTH]'
          : password, // Marcador especial para usuarios externos
      rol: rol,
    );

    return await _repository.createUsuario(usuario);
  }

  Future<void> updateUsuario(Usuario usuario) =>
      _repository.updateUsuario(usuario);
  Future<void> deleteUsuario(int id) => _repository.deleteUsuario(id);

  Future<Usuario?> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email y contraseña son obligatorios');
    }
    return await _repository.login(email.trim().toLowerCase(), password);
  }
}
