import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/roble_config.dart';

class RobleApiDataSource {
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<dynamic> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool isAuthRequest = false,
  }) async {
    try {
      final baseUrl = isAuthRequest ? RobleConfig.authUrl : RobleConfig.dataUrl;
      final headers = isAuthRequest
          ? RobleConfig.authHeaders
          : RobleConfig.dataHeaders;

      final uri = Uri.parse(
        '$baseUrl/$endpoint',
      ).replace(queryParameters: queryParams);

      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(timeoutDuration);
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeoutDuration);
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeoutDuration);
          break;
        case 'DELETE':
          response = await http
              .delete(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeoutDuration);
          break;
        default:
          throw Exception('HTTP method $method not supported');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {};
        return jsonDecode(
          response.body,
        ); // Retorna dynamic (puede ser Map o List)
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error making $method request to $endpoint: $e');
    }
  }

  // ===== MÉTODOS PARA AUTENTICACIÓN =====

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await _makeRequest(
      'POST',
      'login',
      body: {'email': email, 'password': password},
      isAuthRequest: true,
    );
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _makeRequest(
      'POST',
      'signup-direct',
      body: {'email': email, 'password': password, 'name': name},
      isAuthRequest: true,
    );
  }

  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    return await _makeRequest(
      'POST',
      'refresh-token',
      body: {'refreshToken': refreshToken},
      isAuthRequest: true,
    );
  }

  Future<void> logout({required String accessToken}) async {
    await _makeRequest('POST', 'logout', isAuthRequest: true);
  }

  // ===== MÉTODOS PARA GESTIÓN DE ESQUEMAS =====

  Future<void> createTable(
    String tableName,
    List<Map<String, dynamic>> columns,
  ) async {
    await _makeRequest(
      'POST',
      'create-table',
      body: {
        'tableName': tableName,
        'description': 'Tabla $tableName para app móvil',
        'columns': columns,
      },
    );
  }

  Future<Map<String, dynamic>> getTableData(String tableName) async {
    return await _makeRequest(
      'GET',
      'table-data',
      queryParams: {'schema': 'public', 'table': tableName},
    );
  }

  // ===== MÉTODOS CRUD PARA DATOS =====

  Future<Map<String, dynamic>> create(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    print('🔵 Enviando datos: $data');
    print('🔵 Tabla: $tableName');

    final response =
        await _makeRequest(
              'POST',
              'insert',
              body: {
                'tableName': tableName,
                'records': [data],
              },
            )
            as Map<String, dynamic>;

    print('🔵 Respuesta completa: $response');
    print('🔵 Inserted field: ${response['inserted']}');

    if (response['inserted'] != null && response['inserted'].isNotEmpty) {
      return response['inserted'][0];
    }

    if (response.isNotEmpty) {
      return response;
    }

    throw Exception('No se pudo insertar el registro');
  }

  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
    Map<String, String> queryParams = {'tableName': tableName};

    if (filters != null) {
      filters.forEach((key, value) {
        queryParams[key] = value.toString();
      });
    }

    final response = await _makeRequest(
      'GET',
      'read',
      queryParams: queryParams,
    );

    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else if (response is Map && response.containsKey('data')) {
      return List<Map<String, dynamic>>.from(response['data']);
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> update(
    String tableName,
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    // QUITAR _id DEL DATA PARA EVITAR CONFLICTOS
    final updateData = Map<String, dynamic>.from(data);
    updateData.remove('_id'); // No intentar actualizar el ID
    updateData.remove('id'); // Por si acaso

    return await _makeRequest(
      'PUT',
      'update',
      body: {
        'tableName': tableName,
        'idColumn': '_id', // CAMBIAR A '_id' PARA ROBLE
        'idValue': id,
        'updates': updateData,
      },
    );
  }

  Future<Map<String, dynamic>> delete(String tableName, dynamic id) async {
    return await _makeRequest(
      'DELETE',
      'delete',
      body: {
        'tableName': tableName,
        'idColumn': '_id', // CAMBIAR A '_id'
        'idValue': id,
      },
    );
  }

  // ===== MÉTODOS DE CONVENIENCIA =====

  Future<List<Map<String, dynamic>>> getAll(String tableName) async {
    return await read(tableName);
  }

  Future<Map<String, dynamic>?> getById(String tableName, dynamic id) async {
    try {
      final results = await read(tableName, filters: {'_id': id});
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getWhere(
    String tableName,
    String column,
    dynamic value,
  ) async {
    return await read(tableName, filters: {column: value});
  }
}
