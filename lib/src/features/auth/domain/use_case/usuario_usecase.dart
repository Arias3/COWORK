import '../entities/user_entity.dart';
import '../repositories/usuario_repository.dart';

class UsuarioUseCase {
  final UsuarioRepository _repository;

  UsuarioUseCase(this._repository);

  Future<List<Usuario>> getUsuarios() => _repository.getUsuarios();
  Future<Usuario?> getUsuarioById(int id) => _repository.getUsuarioById(id);
  Future<Usuario?> getUsuarioByEmail(String email) => _repository.getUsuarioByEmail(email);
  
  Future<int> createUsuario({
    required String nombre,
    required String email,
    required String password,
    required String rol,
  }) async {
    // Validaciones
    if (nombre.trim().isEmpty) throw Exception('El nombre es obligatorio');
    if (email.trim().isEmpty) throw Exception('El email es obligatorio');
    if (password.trim().isEmpty) throw Exception('La contraseña es obligatoria');
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw Exception('Email no válido');
    }
    
    // Verificar si el email ya existe
    if (await _repository.existeEmail(email)) {
      throw Exception('Este email ya está registrado');
    }

    final usuario = Usuario(
      nombre: nombre.trim(),
      email: email.trim().toLowerCase(),
      password: password, // En producción usar hash
      rol: rol,
    );

    return await _repository.createUsuario(usuario);
  }

  Future<void> updateUsuario(Usuario usuario) => _repository.updateUsuario(usuario);
  Future<void> deleteUsuario(int id) => _repository.deleteUsuario(id);
  
  Future<Usuario?> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email y contraseña son obligatorios');
    }
    return await _repository.login(email.trim().toLowerCase(), password);
  }
}