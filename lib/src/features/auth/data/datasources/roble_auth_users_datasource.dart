import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RobleAuthUsersDatasource {
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/auth/coworkapp_f869bff78c';

  /// Explora endpoints disponibles en RobleAuth para descubrir usuarios
  Future<List<String>> discoverAvailableEndpoints({String? accessToken}) async {
    try {
      print('🔍 RobleAuthUsers: Explorando endpoints disponibles...');

      String? token = accessToken;
      if (token == null) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('roble_auth_token');
      }

      if (token == null) {
        print('❌ RobleAuthUsers: No hay token disponible');
        return [];
      }

      List<String> availableEndpoints = [];

      // Lista de endpoints comunes para probar
      final endpointsToTest = [
        '/users',
        '/user',
        '/profile',
        '/profiles',
        '/members',
        '/accounts',
        '/directory',
        '/search/users',
        '/admin/users',
        '/app/users',
      ];

      for (String endpoint in endpointsToTest) {
        try {
          final response = await http
              .head(
                Uri.parse('$baseUrl$endpoint'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              )
              .timeout(const Duration(seconds: 3));

          if (response.statusCode == 200 || response.statusCode == 201) {
            print(
              '✅ Endpoint disponible: $endpoint (status: ${response.statusCode})',
            );
            availableEndpoints.add(endpoint);
          } else if (response.statusCode != 404) {
            print(
              '⚠️ Endpoint $endpoint responde con status: ${response.statusCode}',
            );
          }
        } catch (e) {
          // Ignorar errores de endpoints no disponibles
        }
      }

      print(
        '📋 Total de endpoints disponibles encontrados: ${availableEndpoints.length}',
      );
      return availableEndpoints;
    } catch (e) {
      print('⚠️ Error explorando endpoints: $e');
      return [];
    }
  }

  /// Verifica si el endpoint /users está disponible
  Future<bool> isUsersEndpointAvailable({String? accessToken}) async {
    try {
      print(
        '🔍 RobleAuthUsers: Verificando disponibilidad del endpoint /users',
      );

      String? token = accessToken;
      if (token == null) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('roble_auth_token');
      }

      if (token == null) {
        print(
          '❌ RobleAuthUsers: No hay token disponible para verificar endpoint',
        );
        return false;
      }

      final response = await http
          .head(
            Uri.parse('$baseUrl/users'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      final available = response.statusCode != 404;
      print(
        '📊 RobleAuthUsers: Endpoint /users disponible: $available (status: ${response.statusCode})',
      );
      return available;
    } catch (e) {
      print('⚠️ RobleAuthUsers: Error verificando endpoint: $e');
      return false;
    }
  }

  /// Busca un usuario específico por email en RobleAuth
  Future<Map<String, dynamic>?> searchUserByEmail({
    required String email,
    required String accessToken,
  }) async {
    try {
      print('🔍 Buscando usuario por email: $email');

      // Intentar varios endpoints de búsqueda
      final searchEndpoints = [
        '/user?email=$email',
        '/users/search?email=$email',
        '/search/user?email=$email',
        '/profile?email=$email',
      ];

      for (String endpoint in searchEndpoints) {
        try {
          final url = Uri.parse('$baseUrl$endpoint');
          print('📡 Probando búsqueda en: $url');

          final response = await http
              .get(
                url,
                headers: {
                  'Authorization': 'Bearer $accessToken',
                  'Content-Type': 'application/json',
                },
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            print('✅ Usuario encontrado en $endpoint: ${data.toString()}');
            return data is Map<String, dynamic> ? data : null;
          } else if (response.statusCode != 404) {
            print(
              '⚠️ Endpoint $endpoint respondió con status: ${response.statusCode}',
            );
          }
        } catch (e) {
          print('⚠️ Error en endpoint $endpoint: $e');
          continue;
        }
      }

      print('❌ Usuario no encontrado con email: $email');
      return null;
    } catch (e) {
      print('⚠️ Error buscando usuario por email: $e');
      return null;
    }
  }

  /// Obtiene todos los usuarios registrados en RobleAuth
  Future<List<Map<String, dynamic>>> getAllUsers({
    required String accessToken,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/users',
      ); // Endpoint para obtener todos los usuarios

      print('📡 Llamando a RobleAuth: GET $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('RobleAuth getAllUsers status: ${response.statusCode}');
      print('RobleAuth getAllUsers body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // La respuesta puede ser directamente una lista o estar dentro de un objeto
        if (responseData is List) {
          return responseData.cast<Map<String, dynamic>>();
        } else if (responseData is Map && responseData.containsKey('users')) {
          return (responseData['users'] as List).cast<Map<String, dynamic>>();
        } else if (responseData is Map && responseData.containsKey('data')) {
          return (responseData['data'] as List).cast<Map<String, dynamic>>();
        } else {
          print('⚠️ Estructura de respuesta inesperada: $responseData');
          return [];
        }
      } else if (response.statusCode == 404) {
        // El endpoint /users no existe en esta versión de RobleAuth
        print('⚠️ Endpoint /users no disponible en RobleAuth');
        print(
          '💡 Nota: Solo se sincronizarán usuarios cuando hagan login individual',
        );
        return [];
      } else {
        String errorMsg = 'Error desconocido';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('message')) {
            errorMsg = decoded['message'].toString();
          } else {
            errorMsg = response.body;
          }
        } catch (_) {
          errorMsg = response.body;
        }

        print('❌ RobleAuth getAllUsers error: $errorMsg');

        // Si es 401 (no autorizado), puede que el token haya expirado
        if (response.statusCode == 401) {
          throw Exception('Token expirado o no autorizado');
        }

        throw Exception('Error obteniendo usuarios: $errorMsg');
      }
    } catch (e) {
      print('❌ Error en getAllUsers: $e');

      // Si es un error de conexión o el endpoint no existe, devolver lista vacía
      // en lugar de fallar completamente
      if (e.toString().contains('Connection') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('SocketException')) {
        print('💡 Continuando sin sincronización masiva de usuarios');
        return [];
      }

      rethrow;
    }
  }
}
