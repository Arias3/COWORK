import 'dart:convert';
import 'package:http/http.dart' as http;

class RobleAuthDatasource {
  final String baseUrl = 'https://roble-api.openlab.uninorte.edu.co/auth/coworkapp_dd7a0b82de';

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final url = Uri.parse('$baseUrl/signup-direct');
    final requestBody = {'email': email, 'password': password, 'name': name};

    print('RobleAuth register URL: $url');
    print('RobleAuth register body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print('RobleAuth register status: ${response.statusCode}');
    print('RobleAuth register response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      // Extrae el mensaje del backend si existe
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
      print('RobleAuth error: $errorMsg');
      throw Exception('RobleAuth error: $errorMsg');
    }
  }
}
