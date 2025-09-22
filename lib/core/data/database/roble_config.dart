lass RobleConfig {
  static const String baseUrl = 'https://roble-api.openlab.uninorte.edu.co/database';
  static const String dbName = 'app_movil_0ed23bb2fe';
  static String? accessToken; // Se configurará dinámicamente
  
  static String get fullBaseUrl => '$baseUrl/$dbName';
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${accessToken ?? ""}',
  };
  
  // Flag para determinar qué BD usar
  static bool useRoble = false;
}