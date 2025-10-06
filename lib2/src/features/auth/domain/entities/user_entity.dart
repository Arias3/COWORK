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
  String password;

  @HiveField(4)
  String rol; // 'profesor' o 'estudiante'

  @HiveField(5)
  DateTime creadoEn;

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.rol,
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'password': password,
    'rol': rol,
    'creadoEn': creadoEn.toIso8601String(),
  };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'],
    nombre: json['nombre'],
    email: json['email'],
    password: json['password'],
    rol: json['rol'],
    creadoEn: DateTime.parse(json['creadoEn']),
  );
}
