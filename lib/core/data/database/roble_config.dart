class RobleConfig {
  // Usar tu proyecto para todo (auth y datos)
  static const String baseUrl = 'https://roble-api.openlab.uninorte.edu.co';
  static const String dbName = 'coworkapp_dd7a0b82de'; // Tu proyecto
  static String? accessToken;

  // URLs para auth y datos en tu proyecto
  static String get authUrl => '$baseUrl/auth/$dbName';
  static String get dataUrl => '$baseUrl/database/$dbName';

  static Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> get dataHeaders => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${accessToken ?? ""}',
  };

  static bool useRoble = true;

  static void setAccessToken(String token) {
    accessToken = token;
  }

  static void clearTokens() {
    accessToken = null;
  }
}
