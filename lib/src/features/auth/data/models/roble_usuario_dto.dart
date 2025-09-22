import '../../features/auth/domain/entities/user_entity.dart';

class RobleUsuarioDto {
  final int? id;
  final String nombre;
  final String email;
  final String password;
  final String rol;
  final String creadoEn;

  RobleUsuarioDto({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.rol,
    required this.creadoEn,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'email': email,
    'password': password,
    'rol': rol,
    'creado_en': creadoEn,
  };

  factory RobleUsuarioDto.fromJson(Map<String, dynamic> json) => RobleUsuarioDto(
    id: json['id'],
    nombre: json['nombre'],
    email: json['email'],
    password: json['password'],
    rol: json['rol'],
    creadoEn: json['creado_en'],
  );

  factory RobleUsuarioDto.fromEntity(Usuario usuario) => RobleUsuarioDto(
    id: usuario.id,
    nombre: usuario.nombre,
    email: usuario.email,
    password: usuario.password,
    rol: usuario.rol,
    creadoEn: usuario.creadoEn.toIso8601String(),
  );

  Usuario toEntity() => Usuario(
    id: id,
    nombre: nombre,
    email: email,
    password: password,
    rol: rol,
    creadoEn: DateTime.parse(creadoEn),
  );
}