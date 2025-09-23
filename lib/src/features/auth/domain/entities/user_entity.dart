import 'package:hive/hive.dart';

part 'user_entity.g.dart';

@HiveType(typeId: 0)
class Usuario extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? password;


  @HiveField(4)
  String rol; // 'profesor' o 'estudiante'

  @HiveField(5)
  DateTime creadoEn;

  @HiveField(6)
  String? authUserId; // ID del usuario en el sistema de auth de Roble

  @HiveField(7)
  String? robleId; // ID original como string de Roble (ej: "AfqZEyYldDPq")

  Usuario({
  this.id,
  required this.nombre,
  required this.email,
  this.password, // ahora puede ser null
  required this.rol,
  DateTime? creadoEn,
  this.authUserId,
  this.robleId,
}) : creadoEn = creadoEn ?? DateTime.now();


  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'password': password,
        'rol': rol,
        'creadoEn': creadoEn.toIso8601String(),
        'authUserId': authUserId,
        'robleId': robleId, // 🆕 Incluir en JSON
      };

  /// Crear instancia desde JSON
  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'],
        nombre: json['nombre'],
        email: json['email'],
        password: json['password'],
        rol: json['rol'],
        creadoEn: DateTime.parse(json['creadoEn']),
        authUserId: json['authUserId'],
        robleId: json['robleId'], // 🆕 Leer del JSON
      );

  /// Constructor desde respuesta de auth
  factory Usuario.fromAuthResponse({
    required String authUserId,
    required String nombre,
    required String email,
    required String rol,
  }) =>
      Usuario(
        nombre: nombre,
        email: email,
        password: '',
        rol: rol,
        authUserId: authUserId,
      );

  /// 🆕 Constructor de copia para facilitar actualizaciones
  Usuario copyWith({
    int? id,
    String? nombre,
    String? email,
    String? password,
    String? rol,
    String? authUserId,
    String? robleId,
    DateTime? creadoEn,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      password: password ?? this.password,
      rol: rol ?? this.rol,
      authUserId: authUserId ?? this.authUserId,
      robleId: robleId ?? this.robleId,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  String toString() {
    return 'Usuario(id: $id, nombre: $nombre, email: $email, rol: $rol, robleId: $robleId)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usuario &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
