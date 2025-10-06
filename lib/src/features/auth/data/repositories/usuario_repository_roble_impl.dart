import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import '../models/roble_usuario_dto.dart';

class UsuarioRepositoryRobleImpl implements UsuarioRepository {
  final RobleApiDataSource _dataSource = RobleApiDataSource();
  static const String tableName = 'usuarios';

  @override
  Future<List<Usuario>> getUsuarios() async {
    try {
      final data = await _dataSource.getAll(tableName);
      return data
          .map((json) => RobleUsuarioDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error obteniendo usuarios de Roble: $e');
      return [];
    }
  }

  @override
  Future<Usuario?> getUsuarioById(int id) async {
    try {
      print('[ROBLE] Buscando usuario con ID: $id');

      // Primero intentar obtener directamente por ID
      final data = await _dataSource.getById(tableName, id.toString());
      if (data != null) {
        final usuario = RobleUsuarioDto.fromJson(data).toEntity();
        print('[ROBLE] Usuario encontrado por ID directo: ${usuario.nombre}');
        return usuario;
      }

      // Si no se encuentra, buscar en todos los usuarios y comparar con ID generado
      print(
        '[ROBLE] No encontrado por ID directo, buscando en todos los usuarios...',
      );
      final todosUsuarios = await _dataSource.getAll(tableName);

      for (var userData in todosUsuarios) {
        final usuario = RobleUsuarioDto.fromJson(userData).toEntity();

        // Comparar tanto con el ID directo como con el ID generado
        if (usuario.id == id) {
          print(
            '[ROBLE] Usuario encontrado por coincidencia: ${usuario.nombre}',
          );
          return usuario;
        }

        // También verificar si el ID buscado coincide con el ID generado del email
        final idGenerado = _generateConsistentId(usuario.email);
        if (idGenerado == id) {
          print(
            '[ROBLE] Usuario encontrado por ID generado desde email: ${usuario.nombre}',
          );
          return usuario;
        }

        // Si el usuario tiene un _id de Roble, verificar también con eso
        if (userData['_id'] != null) {
          final idGeneradoRoble = _generateConsistentId(
            userData['_id'].toString(),
          );
          if (idGeneradoRoble == id) {
            print(
              '[ROBLE] Usuario encontrado por ID generado desde _id de Roble: ${usuario.nombre}',
            );
            return usuario;
          }
        }
      }

      print('[ROBLE] Usuario con ID $id no encontrado en ninguna estrategia');
      return null;
    } catch (e) {
      print('[ROBLE] Error obteniendo usuario por ID: $e');
      return null;
    }
  }

  @override
  Future<Usuario?> getUsuarioByEmail(String email) async {
    try {
      final data = await _dataSource.getWhere(tableName, 'email', email);
      return data.isNotEmpty
          ? RobleUsuarioDto.fromJson(data.first).toEntity()
          : null;
    } catch (e) {
      print('Error obteniendo usuario por email de Roble: $e');
      return null;
    }
  }

  @override
  Future<int> createUsuario(Usuario usuario) async {
    try {
      final dto = RobleUsuarioDto.fromEntity(usuario);

      print('[ROBLE] Creando usuario: ${usuario.nombre} (${usuario.email})');
      print('[ROBLE] DTO JSON: ${dto.toJson()}');

      final response = await _dataSource.create(tableName, dto.toJson());
      print('[ROBLE] Respuesta completa de creacion usuario: $response');

      // Extraer ID de la respuesta según estructura de Roble API
      int nuevoId;

      // La respuesta tiene estructura: {inserted: [{_id: "...", ...}], skipped: []}
      if (response['inserted'] != null &&
          response['inserted'] is List &&
          response['inserted'].isNotEmpty) {
        final insertedItem = response['inserted'][0];
        final robleId = insertedItem['_id'];

        print('[ROBLE] ID extraido de inserted[0][_id]: $robleId');

        if (robleId != null) {
          nuevoId = _generateConsistentId(robleId.toString());
        } else {
          nuevoId = _generateConsistentId(usuario.email);
        }
      } else {
        // Fallback: generar ID consistente basado en email
        nuevoId = _generateConsistentId(usuario.email);
        print('[ROBLE] Fallback - ID generado para email: ${usuario.email}');
      }

      print('[ROBLE] Usuario creado con ID final: $nuevoId');
      return nuevoId;
    } catch (e) {
      print('[ROBLE] Error creando usuario: $e');
      throw Exception('No se pudo crear el usuario: $e');
    }
  }

  @override
  Future<void> updateUsuario(Usuario usuario) async {
    try {
      final dto = RobleUsuarioDto.fromEntity(usuario);
      await _dataSource.update(tableName, usuario.id.toString(), dto.toJson());
    } catch (e) {
      print('Error actualizando usuario en Roble: $e');
      throw Exception('No se pudo actualizar el usuario: $e');
    }
  }

  @override
  Future<void> deleteUsuario(int id) async {
    try {
      await _dataSource.delete(tableName, id.toString());
    } catch (e) {
      print('Error eliminando usuario de Roble: $e');
      throw Exception('No se pudo eliminar el usuario: $e');
    }
  }

  @override
  Future<bool> existeEmail(String email) async {
    try {
      final usuario = await getUsuarioByEmail(email);
      return usuario != null;
    } catch (e) {
      print('Error verificando email en Roble: $e');
      return false;
    }
  }

  @override
  Future<Usuario?> login(String email, String password) async {
    try {
      final usuario = await getUsuarioByEmail(email);
      return usuario;
    } catch (e) {
      print('Error en login de Roble: $e');
      return null;
    }
  }

  @override
  Future<Usuario?> getUsuarioByAuthId(String authUserId) async {
    try {
      final data = await _dataSource.getWhere(
        tableName,
        'auth_user_id',
        authUserId,
      );
      return data.isNotEmpty
          ? RobleUsuarioDto.fromJson(data.first).toEntity()
          : null;
    } catch (e) {
      print('Error obteniendo usuario por auth ID de Roble: $e');
      return null;
    }
  }

  // ========================================================================
  // FUNCIÓN DETERMINÍSTICA PARA IDs CONSISTENTES CROSS-PLATFORM
  // ========================================================================
  static int _generateConsistentId(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      int char = input.codeUnitAt(i);
      hash = ((hash << 5) - hash + char) & 0x7FFFFFFF;
    }
    return hash == 0 ? 1 : hash; // Evitar 0
  }
}
