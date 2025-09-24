import '../entities/user_entity.dart';
import '../repositories/usuario_repository.dart';

// Extensión para firstWhereOrNull si no está disponible
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class UsuarioUseCase {
  final UsuarioRepository _repository;

  UsuarioUseCase(this._repository);

  Future<List<Usuario>> getUsuarios() => _repository.getUsuarios();
  Future<Usuario?> getUsuarioById(int id) => _repository.getUsuarioById(id);
  Future<Usuario?> getUsuarioByEmail(String email) => _repository.getUsuarioByEmail(email);
  
  // ========================================================================
  // MÉTODO ORIGINAL DE CREACIÓN DE USUARIO (mantener compatibilidad)
  // ========================================================================
  Future<int> createUsuario({
    required String nombre,
    required String email,
    required String password,
    required String rol,
  }) async {
    // Validaciones existentes
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

    // Generar nuevo ID único
    final usuarios = await _repository.getUsuarios();
    final nuevoId = usuarios.isEmpty 
      ? 1 
      : usuarios.map((u) => u.id!).reduce((a, b) => a > b ? a : b) + 1;

    final usuario = Usuario(
      id: nuevoId,
      nombre: nombre.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      rol: rol,
    );

    return await _repository.createUsuario(usuario);
  }

  // ========================================================================
  // NUEVOS MÉTODOS PARA MANEJO DE ROLES Y ROBLEAUTH
  // ========================================================================

  /// Crear usuario desde RobleAuth (sin contraseña obligatoria)
  Future<int?> createUsuarioFromAuth({
  required String nombre,
  required String email,
  String? authUserId,
  String? rol, // Este parámetro ahora solo sirve para forzar un rol explícito opcional
}) async {
  print("DEBUG createUsuarioFromAuth:");
  print("  Email recibido: '$email'");
  print("  Rol recibido (antes de detección): '$rol'");
  
  try {
    // Validaciones básicas
    if (nombre.trim().isEmpty) throw Exception('El nombre es obligatorio');
    if (email.trim().isEmpty) throw Exception('El email es obligatorio');
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw Exception('Email no válido');
    }

    // Limpiar email
    final emailLimpio = email.trim().toLowerCase();

    // Verificar si ya existe
    final usuarioExistente = await _repository.getUsuarioByEmail(emailLimpio);
    if (usuarioExistente != null) {
      print('Usuario ya existe: ${usuarioExistente.id}');
      return usuarioExistente.id;
    }

    // Detectar rol automáticamente **ignorar rol de RobleAuth si es "user"**
    final rolFinal = (rol == null || rol == "user") 
    ? detectarRolPorEmail(emailLimpio)
    : rol;


    print("Rol final asignado: $rolFinal");

    // Generar ID único
    final usuarios = await _repository.getUsuarios();
    final nuevoId = usuarios.isEmpty 
        ? 1 
        : usuarios.map((u) => u.id!).reduce((a, b) => a > b ? a : b) + 1;

    final usuario = Usuario(
      id: nuevoId,
      nombre: nombre.trim(),
      email: emailLimpio,
      authUserId: authUserId,
      rol: rolFinal,
      password: null, // RobleAuth no maneja contraseñas locales
    );

    print('Creando usuario desde Auth: $nombre ($emailLimpio) como $rolFinal');

    final resultId = await _repository.createUsuario(usuario);

    print('Usuario creado exitosamente con ID: $resultId');
    return resultId;

  } catch (e) {
    print('Error creando usuario desde Auth: $e');
    return null;
  }
}


  /// Detecta el rol automáticamente basado en el email
  String detectarRolPorEmail(String email) {
  // Limpiar email
  final emailLimpio = email.trim();
  final emailLower = emailLimpio.toLowerCase();

  print("DEBUG _detectarRolPorEmail:");
  print("  Email original: '$email'");
  print("  Email limpio: '$emailLimpio'");
  print("  Email lowercase: '$emailLower'");

  // Emails institucionales
  if (emailLower.contains('@uninorte.edu.co')) {
    print("  Dominio institucional detectado");
    if (RegExp(r'^(profesor|docente|teacher)\.').hasMatch(emailLower)) {
      print("  Prefijo detectado: profesor → rol='profesor'");
      return 'profesor';
    }
    print("  Prefijo no detectado → rol='estudiante'");
    return 'estudiante';
  }

  // Emails externos
  if (emailLower.contains('admin') || emailLower.contains('administrador')) {
    print("  Email contiene 'admin' → rol='admin'");
    return 'admin';
  }
  if (emailLower.contains('profesor') ||
      emailLower.contains('teacher') ||
      emailLower.contains('docente')) {
    print("  Email contiene palabra clave → rol='profesor'");
    return 'profesor';
  }

  print("  Ninguna regla coincide → rol='estudiante'");
  return 'estudiante';
}



  /// Obtiene o crea usuario desde RobleAuth con selección de rol
  Future<Usuario?> obtenerOCrearUsuarioAuth({
    required String nombre,
    required String email,
    String? authUserId,
    String? rolSeleccionado,
  }) async {
    try {
      final emailLimpio = email.trim().toLowerCase();
      
      // Primero intentar obtener usuario existente
      final usuarioExistente = await _repository.getUsuarioByEmail(emailLimpio);
      if (usuarioExistente != null) {
        print('Usuario existente encontrado: ${usuarioExistente.nombre} (${usuarioExistente.rol})');
        return usuarioExistente;
      }
      
      // Usuario nuevo - usar rol seleccionado o detectar automáticamente
      final rolFinal = rolSeleccionado ?? detectarRolPorEmail(emailLimpio);
      
      print('Usuario nuevo detectado. Rol sugerido: $rolFinal');
      
      // Crear usuario
      final nuevoId = await createUsuarioFromAuth(
        nombre: nombre,
        email: emailLimpio,
        authUserId: authUserId,
        rol: rolFinal,
      );
      
      if (nuevoId != null) {
        // Obtener el usuario recién creado
        return await _repository.getUsuarioById(nuevoId);
      }
      
      return null;
    } catch (e) {
      print('Error en obtenerOCrearUsuarioAuth: $e');
      return null;
    }
  }

  /// Cambiar rol de usuario existente
  Future<bool> cambiarRolUsuario(int userId, String nuevoRol) async {
    try {
      if (!['estudiante', 'profesor', 'admin'].contains(nuevoRol)) {
        throw Exception('Rol no válido: $nuevoRol');
      }
      
      final usuario = await _repository.getUsuarioById(userId);
      if (usuario == null) {
        throw Exception('Usuario no encontrado');
      }
      
      if (usuario.rol == nuevoRol) {
        print('Usuario ya tiene el rol: $nuevoRol');
        return true;
      }
      
      print('Cambiando rol de ${usuario.nombre} de ${usuario.rol} a $nuevoRol');
      
      // Crear usuario actualizado
      final usuarioActualizado = Usuario(
        id: usuario.id,
        nombre: usuario.nombre,
        email: usuario.email,
        authUserId: usuario.authUserId,
        rol: nuevoRol,
        password: usuario.password,
        robleId: usuario.robleId,
        creadoEn: usuario.creadoEn,
      );
      
      await _repository.updateUsuario(usuarioActualizado);
      
      print('Rol actualizado exitosamente');
      return true;
      
    } catch (e) {
      print('Error cambiando rol: $e');
      return false;
    }
  }

  /// Cambiar rol por email
  Future<bool> cambiarRolPorEmail(String email, String nuevoRol) async {
    try {
      final usuario = await _repository.getUsuarioByEmail(email.trim().toLowerCase());
      if (usuario?.id == null) {
        throw Exception('Usuario no encontrado con email: $email');
      }
      
      return await cambiarRolUsuario(usuario!.id!, nuevoRol);
    } catch (e) {
      print('Error cambiando rol por email: $e');
      return false;
    }
  }

  /// Sincronizar usuario de RobleAuth con la base de datos
  Future<Usuario?> sincronizarUsuarioAuth(Usuario usuarioAuth) async {
    try {
      if (usuarioAuth.email.trim().isEmpty) {
        throw Exception('Email del usuario auth está vacío');
      }
      
      final emailLimpio = usuarioAuth.email.trim().toLowerCase();
      
      // Buscar usuario en BD
      final usuarioBD = await _repository.getUsuarioByEmail(emailLimpio);
      
      if (usuarioBD != null) {
        print('Sincronizando usuario existente: ${usuarioBD.nombre}');
        
        // Usuario existe, verificar si necesita actualización
        bool necesitaActualizacion = false;
        final usuarioActualizado = Usuario(
          id: usuarioBD.id,
          nombre: usuarioAuth.nombre.isNotEmpty ? usuarioAuth.nombre : usuarioBD.nombre,
          email: usuarioBD.email,
          authUserId: usuarioAuth.authUserId ?? usuarioBD.authUserId,
          rol: usuarioBD.rol, // Mantener rol existente
          password: usuarioBD.password,
          robleId: usuarioAuth.robleId ?? usuarioBD.robleId,
          creadoEn: usuarioBD.creadoEn,
        );
        
        // Verificar si authUserId cambió
        if (usuarioAuth.authUserId != null && usuarioBD.authUserId != usuarioAuth.authUserId) {
          necesitaActualizacion = true;
        }
        
        // Verificar si nombre cambió
        if (usuarioAuth.nombre.isNotEmpty && usuarioBD.nombre != usuarioAuth.nombre) {
          necesitaActualizacion = true;
        }
        
        // Verificar si robleId cambió
        if (usuarioAuth.robleId != null && usuarioBD.robleId != usuarioAuth.robleId) {
          necesitaActualizacion = true;
        }
        
        if (necesitaActualizacion) {
          await _repository.updateUsuario(usuarioActualizado);
          print('Usuario actualizado en BD');
          return usuarioActualizado;
        } else {
          print('Usuario ya está sincronizado');
          return usuarioBD;
        }
      } else {
        // Usuario no existe, crear nuevo con rol detectado automáticamente
        print('Creando nuevo usuario desde sincronización');
        
        final nuevoId = await createUsuarioFromAuth(
          nombre: usuarioAuth.nombre,
          email: emailLimpio,
          authUserId: usuarioAuth.authUserId,
          rol: usuarioAuth.rol?.isNotEmpty == true ? usuarioAuth.rol! : null,
        );
        
        if (nuevoId != null) {
          return await _repository.getUsuarioById(nuevoId);
        }
      }
      
      return null;
    } catch (e) {
      print('Error sincronizando usuario: $e');
      return null;
    }
  }

  /// Validar que un usuario puede realizar una acción específica
  Future<bool> validarPermisoUsuario(int userId, String accion) async {
    try {
      final usuario = await _repository.getUsuarioById(userId);
      if (usuario == null) return false;
      
      switch (accion.toLowerCase()) {
        case 'crear_curso':
          return usuario.rol == 'profesor' || usuario.rol == 'admin';
        case 'inscribirse_curso':
          return usuario.rol == 'estudiante' || usuario.rol == 'admin';
        case 'gestionar_usuarios':
          return usuario.rol == 'admin';
        case 'ver_estadisticas':
          return usuario.rol == 'profesor' || usuario.rol == 'admin';
        case 'modificar_curso':
          return usuario.rol == 'profesor' || usuario.rol == 'admin';
        case 'eliminar_curso':
          return usuario.rol == 'admin';
        default:
          return true; // Acción no específica
      }
    } catch (e) {
      print('Error validando permiso: $e');
      return false;
    }
  }

  /// Validar permiso por email
  Future<bool> validarPermisoUsuarioPorEmail(String email, String accion) async {
    try {
      final usuario = await _repository.getUsuarioByEmail(email.trim().toLowerCase());
      if (usuario?.id == null) return false;
      
      return await validarPermisoUsuario(usuario!.id!, accion);
    } catch (e) {
      print('Error validando permiso por email: $e');
      return false;
    }
  }

  /// Obtener estadísticas de roles
  Future<Map<String, int>> getEstadisticasRoles() async {
    try {
      final usuarios = await _repository.getUsuarios();
      final estadisticas = <String, int>{};
      
      for (final usuario in usuarios) {
        final rol = usuario.rol ?? 'sin_rol';
        estadisticas[rol] = (estadisticas[rol] ?? 0) + 1;
      }
      
      return estadisticas;
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {};
    }
  }

  /// Obtener usuarios por rol
  Future<List<Usuario>> getUsuariosPorRol(String rol) async {
    try {
      final usuarios = await _repository.getUsuarios();
      return usuarios.where((u) => u.rol == rol).toList();
    } catch (e) {
      print('Error obteniendo usuarios por rol: $e');
      return [];
    }
  }

  /// Buscar usuarios por texto (nombre o email)
  Future<List<Usuario>> buscarUsuarios(String query) async {
    try {
      final usuarios = await _repository.getUsuarios();
      final queryLower = query.toLowerCase().trim();
      
      if (queryLower.isEmpty) return usuarios;
      
      return usuarios.where((usuario) {
        return usuario.nombre.toLowerCase().contains(queryLower) ||
               usuario.email.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      print('Error buscando usuarios: $e');
      return [];
    }
  }

  /// Verificar si un email está disponible
  Future<bool> emailDisponible(String email) async {
    try {
      return !(await _repository.existeEmail(email.trim().toLowerCase()));
    } catch (e) {
      print('Error verificando email: $e');
      return false;
    }
  }

  /// Obtener usuarios creados recientemente
  Future<List<Usuario>> getUsuariosRecientes({int limite = 10}) async {
    try {
      final usuarios = await _repository.getUsuarios();
      usuarios.sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
      return usuarios.take(limite).toList();
    } catch (e) {
      print('Error obteniendo usuarios recientes: $e');
      return [];
    }
  }

  /// Limpiar usuarios duplicados (por email)
  Future<int> limpiarUsuariosDuplicados() async {
    try {
      final usuarios = await _repository.getUsuarios();
      final usuariosPorEmail = <String, List<Usuario>>{};
      
      // Agrupar por email
      for (final usuario in usuarios) {
        final email = usuario.email.toLowerCase().trim();
        usuariosPorEmail.putIfAbsent(email, () => []).add(usuario);
      }
      
      // Eliminar duplicados (mantener el que tenga ID más reciente)
      int eliminados = 0;
      for (final entry in usuariosPorEmail.entries) {
        final listaUsuarios = entry.value;
        
        if (listaUsuarios.length > 1) {
          // Ordenar por ID (mantener el más reciente)
          listaUsuarios.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
          
          // Eliminar todos excepto el primero
          for (int i = 1; i < listaUsuarios.length; i++) {
            final usuarioAEliminar = listaUsuarios[i];
            if (usuarioAEliminar.id != null) {
              try {
                await _repository.deleteUsuario(usuarioAEliminar.id!);
                eliminados++;
                print('Eliminado duplicado: ${usuarioAEliminar.nombre} (ID: ${usuarioAEliminar.id})');
              } catch (e) {
                print('Error eliminando usuario ${usuarioAEliminar.id}: $e');
              }
            }
          }
        }
      }
      
      print('Limpieza completada. Usuarios eliminados: $eliminados');
      return eliminados;
      
    } catch (e) {
      print('Error en limpieza: $e');
      return 0;
    }
  }

  // ========================================================================
  // MÉTODOS ORIGINALES (mantener compatibilidad)
  // ========================================================================
  Future<void> updateUsuario(Usuario usuario) => _repository.updateUsuario(usuario);
  Future<void> deleteUsuario(int id) => _repository.deleteUsuario(id);
  
  Future<Usuario?> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email y contraseña son obligatorios');
    }
    return await _repository.login(email.trim().toLowerCase(), password);
  }
}