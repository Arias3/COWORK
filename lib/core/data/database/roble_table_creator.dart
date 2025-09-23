import '../datasources/roble_api_datasource.dart';

class RobleTableCreator {
  final RobleApiDataSource _dataSource = RobleApiDataSource();

  Future<void> createAllTables() async {
    print('🚀 Iniciando creación de tablas en Roble...');

    try {
      await _createUsuariosTable();
      await _createCursosTable();
      await _createInscripcionesTable();
      await _createCategoriasEquipoTable();
      await _createEquiposTable();
      await _createActivitiesTable();

      print('✅ Todas las tablas creadas exitosamente en Roble');
    } catch (e) {
      print('❌ Error creando tablas: $e');
      rethrow;
    }
  }

  Future<void> _createUsuariosTable() async {
  print('📝 Creando tabla usuarios...');
  await _dataSource.createTable('usuarios', [
    {'name': 'id', 'type': 'integer', 'isPrimary': true},
    {'name': 'nombre', 'type': 'varchar(255)', 'isNullable': false},
    {'name': 'email', 'type': 'varchar(255)', 'isNullable': false},
    {'name': 'password', 'type': 'varchar(255)', 'isNullable': true}, // Nullable porque no guardamos password aquí
    {'name': 'rol', 'type': 'varchar(50)', 'isNullable': false},
    {'name': 'creado_en', 'type': 'timestamp', 'isNullable': false},
    {'name': 'auth_user_id', 'type': 'varchar(255)', 'isNullable': true}, // 🆕 Referencia al usuario de auth
  ]);
}

  Future<void> _createCursosTable() async {
    print('📝 Creando tabla cursos...');
    await _dataSource.createTable('cursos', [
      {'name': 'id', 'type': 'integer', 'isPrimary': true},
      {'name': 'nombre', 'type': 'varchar(255)', 'isNullable': false},
      {'name': 'descripcion', 'type': 'text', 'isNullable': false},
      {'name': 'profesor_id', 'type': 'integer', 'isNullable': false},
      {'name': 'codigo_registro', 'type': 'varchar(100)', 'isNullable': false},
      {'name': 'creado_en', 'type': 'timestamp', 'isNullable': false},
      {'name': 'categorias', 'type': 'text', 'isNullable': true},
      {'name': 'imagen', 'type': 'varchar(500)', 'isNullable': true},
      {'name': 'estudiantes_nombres', 'type': 'text', 'isNullable': true},
    ]);
  }

  Future<void> _createInscripcionesTable() async {
    print('📝 Creando tabla inscripciones...');
    await _dataSource.createTable('inscripciones', [
      {'name': 'id', 'type': 'integer', 'isPrimary': true},
      {'name': 'usuario_id', 'type': 'integer', 'isNullable': false},
      {'name': 'curso_id', 'type': 'integer', 'isNullable': false},
      {'name': 'fecha_inscripcion', 'type': 'timestamp', 'isNullable': false},
    ]);
  }

  Future<void> _createCategoriasEquipoTable() async {
    print('📝 Creando tabla categorias_equipo...');
    await _dataSource.createTable('categorias_equipo', [
      {'name': 'id', 'type': 'integer', 'isPrimary': true},
      {'name': 'nombre', 'type': 'varchar(255)', 'isNullable': false},
      {'name': 'curso_id', 'type': 'integer', 'isNullable': false},
      {'name': 'tipo_asignacion', 'type': 'varchar(50)', 'isNullable': false},
      {'name': 'max_estudiantes_por_equipo', 'type': 'integer', 'isNullable': false},
      {'name': 'equipos_ids', 'type': 'text', 'isNullable': true},
      {'name': 'creado_en', 'type': 'timestamp', 'isNullable': false},
      {'name': 'equipos_generados', 'type': 'boolean', 'isNullable': false},
      {'name': 'descripcion', 'type': 'text', 'isNullable': true},
    ]);
  }

  Future<void> _createEquiposTable() async {
    print('📝 Creando tabla equipos...');
    await _dataSource.createTable('equipos', [
      {'name': 'id', 'type': 'integer', 'isPrimary': true},
      {'name': 'nombre', 'type': 'varchar(255)', 'isNullable': false},
      {'name': 'categoria_id', 'type': 'integer', 'isNullable': false},
      {'name': 'estudiantes_ids', 'type': 'text', 'isNullable': true},
      {'name': 'creado_en', 'type': 'timestamp', 'isNullable': false},
      {'name': 'descripcion', 'type': 'text', 'isNullable': true},
      {'name': 'color', 'type': 'varchar(50)', 'isNullable': true},
    ]);
  }

  Future<void> _createActivitiesTable() async {
    print('📝 Creando tabla activities...');
    await _dataSource.createTable('activities', [
      {'name': 'id', 'type': 'varchar(50)', 'isPrimary': true},
      {'name': 'category_id', 'type': 'integer', 'isNullable': false},
      {'name': 'name', 'type': 'varchar(255)', 'isNullable': false},
      {'name': 'description', 'type': 'text', 'isNullable': false},
      {'name': 'delivery_date', 'type': 'timestamp', 'isNullable': false},
    ]);
  }
}