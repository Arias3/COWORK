import 'dart:convert';
import 'package:http/http.dart' as http;

class RobleAuthLoginDatasource {
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/auth/coworkapp_f869bff78c';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('RobleAuth login status: [33m${response.statusCode}[0m');
    print('RobleAuth login body: [36m${response.body}[0m');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
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
      print('RobleAuth login error: $errorMsg');
      throw Exception('RobleAuth login error: $errorMsg');
    }
  }
}
