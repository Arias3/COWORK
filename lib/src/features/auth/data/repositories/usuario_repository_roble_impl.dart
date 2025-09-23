import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import '../models/roble_usuario_dto.dart';

class UsuarioRepositoryRobleImpl implements UsuarioRepository {
  final RobleApiDataSource _dataSource = RobleApiDataSource();
  static const String tableName = 'usuarios';
  
  // SISTEMA DE MAPEO DE IDs COMO EN EQUIPOS
  static final Map<String, int> _robleToLocal = {};
  static final Map<int, String> _localToRoble = {};

  void _guardarMapeoId(String robleId, int localId) {
    try {
      _robleToLocal[robleId] = localId;
      _localToRoble[localId] = robleId;
      print('👤 [USER] Mapeo ID guardado: "$robleId" <-> $localId');
    } catch (e) {
      print('⚠️ [USER] Error guardando mapeo: $e');
    }
  }

  String? _obtenerRobleIdOriginal(int localId) {
    return _localToRoble[localId];
  }

  int? _convertirAIdValido(String robleId) {
    try {
      if (robleId.isEmpty) return null;
      
      final existingLocalId = _robleToLocal[robleId];
      if (existingLocalId != null) {
        return existingLocalId;
      }
      
      final hashCode = robleId.hashCode;
      final validId = hashCode.abs() % 0x7FFFFFFF;
      final finalId = validId == 0 ? 1 : validId;
      
      return finalId;
    } catch (e) {
      print('❌ [USER] Error en conversión: $e');
      return null;
    }
  }

  @override
  Future<List<Usuario>> getUsuarios() async {
    try {
      print('🔍 [REPO] Obteniendo todos los usuarios de Roble...');
      final data = await _dataSource.getAll(tableName);
      print('📊 [REPO] Datos recibidos: ${data.length} usuarios');
      
      final usuarios = <Usuario>[];
      
      for (var json in data) {
        try {
          final dto = RobleUsuarioDto.fromJson(json);
          final usuario = dto.toEntity();
          
          // GUARDAR MAPEO
          if (dto.id != null && usuario.id != null) {
            _guardarMapeoId(dto.id!, usuario.id!);
          }
          
          usuarios.add(usuario);
        } catch (e) {
          print('⚠️ [REPO] Error mapeando usuario: $e');
          print('📝 [REPO] JSON problemático: $json');
        }
      }
      
      print('✅ [REPO] ${usuarios.length} usuarios mapeados correctamente');
      return usuarios;
    } catch (e) {
      print('❌ [REPO] Error obteniendo usuarios de Roble: $e');
      return [];
    }
  }

  @override
  Future<Usuario?> getUsuarioById(int id) async {
    try {
      print('🔍 [REPO] Buscando usuario por ID: $id');
      print('🔍 [REPO] Mapeos actuales: $_localToRoble');
      
      final robleId = _obtenerRobleIdOriginal(id);
      
      if (robleId != null) {
        print('🔄 [REPO] Buscando con Roble ID: $robleId');
        final data = await _dataSource.getById(tableName, robleId);
        
        if (data != null) {
          print('✅ [REPO] Data encontrado: $data');
          final dto = RobleUsuarioDto.fromJson(data);
          final usuario = dto.toEntity();
          print('✅ [REPO] Usuario encontrado: ${usuario.nombre}');
          return usuario;
        } else {
          print('❌ [REPO] Data null para Roble ID: $robleId');
        }
      } else {
        print('⚠️ [REPO] No se encontró mapeo para ID local: $id');
        
        // FALLBACK: Buscar en todos los usuarios y recrear mapeo
        print('🔄 [REPO] Iniciando búsqueda fallback...');
        final todosUsuarios = await getUsuarios(); // Esto recrea los mapeos
        
        for (var usuario in todosUsuarios) {
          if (usuario.id == id) {
            print('✅ [REPO] Usuario encontrado en fallback: ${usuario.nombre}');
            return usuario;
          }
        }
      }
      
      return null;
    } catch (e) {
      print('❌ [REPO] Error: $e');
      return null;
    }
  }

  @override
  Future<Usuario?> getUsuarioByEmail(String email) async {
    try {
      print('🔍 [REPO] Buscando usuario por email: "$email"');
      final data = await _dataSource.getWhere(tableName, 'email', email.toLowerCase());
      
      if (data.isNotEmpty) {
        final dto = RobleUsuarioDto.fromJson(data.first);
        final usuario = dto.toEntity();
        
        // GUARDAR MAPEO
        if (dto.id != null && usuario.id != null) {
          _guardarMapeoId(dto.id!, usuario.id!);
        }
        
        print('✅ [REPO] Usuario encontrado: ${usuario.nombre} (ID: ${usuario.id})');
        return usuario;
      } else {
        print('❌ [REPO] No se encontró usuario con email: "$email"');
        return null;
      }
    } catch (e) {
      print('❌ [REPO] Error obteniendo usuario por email de Roble: $e');
      return null;
    }
  }

  @override
  Future<int> createUsuario(Usuario usuario) async {
    try {
      print('🆕 [REPO] Creando usuario en Roble: ${usuario.nombre}');
      
      final dto = RobleUsuarioDto.fromEntity(usuario);
      final response = await _dataSource.create(tableName, dto.toJson());
      
      print('📝 [REPO] Respuesta de Roble: $response');
      
      // Extraer ID de la respuesta
      final robleId = _extraerIdDeRespuestaRoble(response);
      
      if (robleId != null) {
        final localId = _convertirAIdValido(robleId);
        
        if (localId != null && localId > 0) {
          _guardarMapeoId(robleId, localId);
          print('✅ [REPO] Usuario creado con ID: $localId');
          return localId;
        }
      }
      
      throw Exception('No se pudo extraer ID válido de la respuesta');
      
    } catch (e) {
      print('❌ [REPO] Error creando usuario en Roble: $e');
      throw Exception('No se pudo crear el usuario: $e');
    }
  }

  @override
  Future<void> updateUsuario(Usuario usuario) async {
    try {
      print('🔄 [REPO] Actualizando usuario: ${usuario.nombre}');
      
      final robleId = _obtenerRobleIdOriginal(usuario.id!);
      
      if (robleId != null) {
        final dto = RobleUsuarioDto.fromEntity(usuario);
        await _dataSource.update(tableName, robleId, dto.toJson());
        print('✅ [REPO] Usuario actualizado correctamente');
      } else {
        throw Exception('No se encontró ID de Roble para el usuario');
      }
    } catch (e) {
      print('❌ [REPO] Error actualizando usuario en Roble: $e');
      throw Exception('No se pudo actualizar el usuario: $e');
    }
  }

  @override
  Future<void> deleteUsuario(int id) async {
    try {
      print('🗑️ [REPO] Eliminando usuario con ID: $id');
      
      final robleId = _obtenerRobleIdOriginal(id);
      
      if (robleId != null) {
        await _dataSource.delete(tableName, robleId);
        
        // Limpiar mapeos
        _robleToLocal.remove(robleId);
        _localToRoble.remove(id);
        
        print('✅ [REPO] Usuario eliminado correctamente');
      } else {
        throw Exception('No se encontró ID de Roble para el usuario');
      }
    } catch (e) {
      print('❌ [REPO] Error eliminando usuario de Roble: $e');
      throw Exception('No se pudo eliminar el usuario: $e');
    }
  }

  @override
  Future<bool> existeEmail(String email) async {
    try {
      final usuario = await getUsuarioByEmail(email);
      return usuario != null;
    } catch (e) {
      print('❌ [REPO] Error verificando email en Roble: $e');
      return false;
    }
  }

  @override
  Future<Usuario?> login(String email, String password) async {
    try {
      final usuario = await getUsuarioByEmail(email);
      
      if (usuario != null && usuario.password == password) {
        print('✅ [REPO] Login exitoso para: ${usuario.nombre}');
        return usuario;
      }
      
      print('❌ [REPO] Credenciales inválidas');
      return null;
    } catch (e) {
      print('❌ [REPO] Error en login con Roble: $e');
      return null;
    }
  }

  @override
  Future<Usuario?> getUsuarioByAuthId(String authUserId) async {
    try {
      print('🔍 [REPO] Buscando usuario por authUserId: "$authUserId"');
      final data = await _dataSource.getWhere(tableName, 'auth_user_id', authUserId);
      
      if (data.isNotEmpty) {
        final dto = RobleUsuarioDto.fromJson(data.first);
        final usuario = dto.toEntity();
        
        // GUARDAR MAPEO
        if (dto.id != null && usuario.id != null) {
          _guardarMapeoId(dto.id!, usuario.id!);
        }
        
        print('✅ [REPO] Usuario encontrado por authUserId: ${usuario.nombre}');
        return usuario;
      } else {
        print('❌ [REPO] No se encontró usuario con authUserId: "$authUserId"');
        return null;
      }
    } catch (e) {
      print('❌ [REPO] Error buscando por authUserId: $e');
      return null;
    }
  }

  // MÉTODO HELPER PARA EXTRAER ID DE RESPUESTA
  String? _extraerIdDeRespuestaRoble(dynamic response) {
    try {
      if (response == null) return null;
      
      // Caso 1: Respuesta directa con _id
      if (response is Map<String, dynamic> && response.containsKey('_id')) {
        return response['_id']?.toString();
      }
      
      // Caso 2: Respuesta con id
      if (response is Map<String, dynamic> && response.containsKey('id')) {
        return response['id']?.toString();
      }
      
      // Caso 3: Estructura {inserted: [...]}
      if (response is Map<String, dynamic> && response.containsKey('inserted')) {
        final inserted = response['inserted'];
        
        if (inserted is List && inserted.isNotEmpty) {
          final firstItem = inserted.first;
          
          if (firstItem is Map<String, dynamic>) {
            final rawId = firstItem['_id'] ?? firstItem['id'];
            return rawId?.toString();
          }
        }
      }
      
      return response?.toString();
      
    } catch (e) {
      print('❌ [USER] Error extrayendo ID: $e');
      return null;
    }
  }
}