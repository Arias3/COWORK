import 'dart:convert';
import 'package:http/http.dart' as http;

class RobleApiDataSource {
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('${RobleConfig.fullBaseUrl}/$endpoint')
          .replace(queryParameters: queryParams);

      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: RobleConfig.headers)
              .timeout(timeoutDuration);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: RobleConfig.headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(timeoutDuration);
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: RobleConfig.headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(timeoutDuration);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: RobleConfig.headers)
              .timeout(timeoutDuration);
          break;
        default:
          throw Exception('HTTP method $method not supported');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {};
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error making $method request to $endpoint: $e');
    }
  }

  // Crear tabla
  Future<void> createTable(String tableName, List<Map<String, dynamic>> columns) async {
    await _makeRequest('POST', 'create-table', body: {
      'tableName': tableName,
      'description': 'Tabla $tableName para app móvil',
      'columns': columns,
    });
  }

  // Obtener datos de tabla
  Future<Map<String, dynamic>> getTableData(String tableName) async {
    return await _makeRequest('GET', 'table-data', queryParams: {
      'schema': 'public',
      'table': tableName,
    });
  }

  // CRUD genérico (adaptado a la API de Roble)
  Future<List<Map<String, dynamic>>> getAll(String tableName) async {
    final response = await getTableData(tableName);
    return List<Map<String, dynamic>>.from(response['rows'] ?? []);
  }

  Future<Map<String, dynamic>?> getById(String tableName, dynamic id) async {
    final all = await getAll(tableName);
    try {
      return all.firstWhere((item) => item['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getWhere(
    String tableName,
    String column,
    dynamic value,
  ) async {
    final all = await getAll(tableName);
    return all.where((item) => item[column] == value).toList();
  }

  // Nota: Estos métodos necesitarán ser implementados según la API final de Roble
  // Por ahora son placeholders que usan la estructura esperada
  Future<Map<String, dynamic>> create(String tableName, Map<String, dynamic> data) async {
    // Implementar cuando tengas el endpoint de INSERT
    throw UnimplementedError('Create operation pending Roble API implementation');
  }

  Future<void> update(String tableName, dynamic id, Map<String, dynamic> data) async {
    // Implementar cuando tengas el endpoint de UPDATE
    throw UnimplementedError('Update operation pending Roble API implementation');
  }

  Future<void> delete(String tableName, dynamic id) async {
    // Implementar cuando tengas el endpoint de DELETE
    throw UnimplementedError('Delete operation pending Roble API implementation');
  }
}