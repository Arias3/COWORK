import '../../domain/entities/user_entity.dart';

class RobleUsuarioDto {
  final String? id; // Mantener como string de Roble
  final String nombre;
  final String email;
  final String? password; // 🔧 Ahora opcional (nullable)
  final String rol;
  final String? authUserId;
  final String? creadoEn;

  RobleUsuarioDto({
    this.id,
    required this.nombre,
    required this.email,
    this.password, // 🔧 ya no es obligatorio
    required this.rol,
    this.authUserId,
    this.creadoEn,
  });

  factory RobleUsuarioDto.fromJson(Map<String, dynamic> json) {
    print('🔍 [DTO] JSON recibido de Roble: $json');

    final robleId = json['_id'] ?? json['id'];
    print('🆔 [DTO] ID extraído: "$robleId" (tipo: ${robleId?.runtimeType})');

    final dto = RobleUsuarioDto(
      id: robleId?.toString(),
      nombre: json['nombre'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'], // 🔧 puede ser null
      rol: json['rol'] ?? json['role'] ?? 'estudiante',
      authUserId: json['auth_user_id'] ?? json['authUserId'],
      creadoEn: json['creado_en'] ?? json['created_at'],
    );

    print(
      '📋 [DTO] DTO creado - ID: "${dto.id}", Nombre: "${dto.nombre}", Rol: "${dto.rol}"',
    );
    return dto;
  }

  factory RobleUsuarioDto.fromEntity(Usuario usuario) {
    print('📤 [DTO] Convirtiendo Usuario a DTO...');
    print('   - Usuario ID: ${usuario.id}');
    print('   - Usuario robleId: ${usuario.robleId}');

    String? robleId = usuario.robleId;

    return RobleUsuarioDto(
      id: robleId,
      nombre: usuario.nombre,
      email: usuario.email,
      password: (usuario.password == null || usuario.password!.isEmpty)
          ? null
          : usuario.password, // 🔧 ya no rompe
      rol: usuario.rol,
      authUserId: usuario.authUserId,
      creadoEn: usuario.creadoEn.toIso8601String(),
    );
  }

  Usuario toEntity() {
    print('🔄 [DTO] Convirtiendo DTO a Usuario...');
    print('   - Roble ID: "$id"');
    print('   - Nombre: "$nombre"');
    print('   - Rol: "$rol"');

    int? finalId;

    if (id != null && id!.isNotEmpty) {
      // ✅ SOLUCIONADO: Usar función determinística en lugar de hashCode
      finalId = _generateConsistentId(id!);
    } else if (email.isNotEmpty) {
      // ✅ SOLUCIONADO: También para email
      finalId = _generateConsistentId(email);
    } else {
      finalId = DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;
    }

    final usuario = Usuario(
      id: finalId,
      nombre: nombre,
      email: email,
      password: password ?? '', // 🔧 nunca null en la entidad
      rol: rol,
      authUserId: authUserId,
      robleId: id,
      creadoEn: creadoEn != null
          ? DateTime.tryParse(creadoEn!) ?? DateTime.now()
          : DateTime.now(),
    );

    print(
      '✅ [DTO] Usuario final: ${usuario.nombre} (ID: ${usuario.id}, Rol: ${usuario.rol}, RobleID: ${usuario.robleId})',
    );
    return usuario;
  }

  Map<String, dynamic> toJson() {
    final json = {
      'nombre': nombre,
      'email': email.toLowerCase().trim(),
      if (password != null) 'password': password, // 🔧 solo si existe
      'rol': rol,
      'creado_en': creadoEn ?? DateTime.now().toIso8601String(),
    };

    if (id != null && id!.isNotEmpty) {
      json['_id'] = id!;
    }
    if (authUserId != null && authUserId!.isNotEmpty) {
      json['auth_user_id'] = authUserId!;
    }

    print('📤 [DTO] JSON para Roble: $json');
    return json;
  }

  /// ✅ MÉTODO AGREGADO: Genera un ID consistente entre plataformas
  /// En lugar de usar hashCode (que varía entre web/mobile),
  /// usamos una función determinística basada en los códigos de caracteres
  int _generateConsistentId(String input) {
    if (input.isEmpty) return 1;

    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = (hash * 31 + input.codeUnitAt(i)) & 0x7FFFFFFF;
    }

    // Asegurar que nunca sea 0
    return hash == 0 ? 1 : hash;
  }
}
