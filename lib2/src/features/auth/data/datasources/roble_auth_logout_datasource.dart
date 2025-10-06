import 'dart:convert';
import 'package:http/http.dart' as http;

class RobleAuthLogoutDatasource {
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/auth/coworkapp_f869bff78c';

  Future<bool> logout({required String accessToken}) async {
    final url = Uri.parse('$baseUrl/logout');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
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
      print('RobleAuth logout error: $errorMsg');
      throw Exception('RobleAuth logout error: $errorMsg');
    }
  }
}
