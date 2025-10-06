import 'dart:convert';
import 'package:http/http.dart' as http;

class RobleAuthRefreshTokenDatasource {
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/auth/coworkapp_dd7a0b82de';

  Future<String> refreshToken({required String refreshToken}) async {
    final url = Uri.parse('$baseUrl/refresh-token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('accessToken')) {
        return decoded['accessToken'].toString();
      } else {
        throw Exception('No se recibió accessToken en la respuesta');
      }
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
      print('RobleAuth refresh error: $errorMsg');
      throw Exception('RobleAuth refresh error: $errorMsg');
    }
  }
}
