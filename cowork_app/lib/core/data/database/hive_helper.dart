import 'package:hive_flutter/hive_flutter.dart';
import '../../../src/features/auth/domain/entities/user_entity.dart';
import '../../../src/features/home/domain/entities/curso_entity.dart';
import '../../../src/features/home/domain/entities/inscripcion_entity.dart';

class HiveHelper {
  static const String usuariosBox = 'usuarios';
  static const String cursosBox = 'cursos';
  static const String inscripcionesBox = 'inscripciones';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    
    // Registrar adapters
    Hive.registerAdapter(UsuarioAdapter());
    Hive.registerAdapter(CursoDomainAdapter());
    Hive.registerAdapter(InscripcionAdapter());

    // Abrir boxes
    await Hive.openBox<Usuario>(usuariosBox);
    await Hive.openBox<CursoDomain>(cursosBox);
    await Hive.openBox<Inscripcion>(inscripcionesBox);

    // Cargar datos iniciales si no existen
    await _loadInitialData();
  }

  static Future<void> _loadInitialData() async {
    final usuariosBoxInstance = Hive.box<Usuario>(usuariosBox);
    final cursosBoxInstance = Hive.box<CursoDomain>(cursosBox);
    final inscripcionesBoxInstance = Hive.box<Inscripcion>(inscripcionesBox);

    // Solo cargar datos si las cajas están vacías
    if (usuariosBoxInstance.isEmpty) {
      // Crear usuarios de prueba
      final usuarios = [
        Usuario(
          id: 1,
          nombre: 'Profesor A',
          email: 'a@a.com',
          password: '123456',
          rol: 'profesor',
        ),
        Usuario(
          id: 2,
          nombre: 'Estudiante B',
          email: 'b@b.com',
          password: '123456',
          rol: 'estudiante',
        ),
        Usuario(
          id: 3,
          nombre: 'Estudiante C',
          email: 'c@c.com',
          password: '123456',
          rol: 'estudiante',
        ),
      ];

      for (var usuario in usuarios) {
        await usuariosBoxInstance.put(usuario.id, usuario);
      }
    }

    if (cursosBoxInstance.isEmpty) {
      // Crear cursos de prueba
      final cursos = [
        CursoDomain(
          id: 1,
          nombre: 'Cálculo Diferencial',
          descripcion: 'Curso completo de cálculo diferencial para ingeniería',
          profesorId: 1,
          codigoRegistro: 'CAL001',
          imagen: 'assets/images/calculo.png',
          categorias: ['Matemáticas', 'Ciencias'],
          estudiantesNombres: ['Ana García', 'Luis Martínez'],
        ),
        CursoDomain(
          id: 2,
          nombre: 'Análisis de Datos',
          descripcion: 'Aprende a analizar datos con Python y R',
          profesorId: 1,
          codigoRegistro: 'ANA002',
          imagen: 'assets/images/analisis.png',
          categorias: ['Programación', 'Tecnología'],
          estudiantesNombres: ['Carlos Ruiz'],
        ),
        CursoDomain(
          id: 3,
          nombre: 'Flutter Avanzado',
          descripcion: 'Desarrollo de aplicaciones móviles avanzadas',
          profesorId: 1,
          codigoRegistro: 'FLU003',
          imagen: 'assets/images/flutter.png',
          categorias: ['Programación', 'Tecnología'],
          estudiantesNombres: [],
        ),
      ];

      for (var curso in cursos) {
        await cursosBoxInstance.put(curso.id, curso);
      }
    }

    if (inscripcionesBoxInstance.isEmpty) {
      // Crear inscripciones de prueba
      final inscripciones = [
        Inscripcion(id: 1, usuarioId: 2, cursoId: 3),
        Inscripcion(id: 2, usuarioId: 3, cursoId: 3),
      ];

      for (var inscripcion in inscripciones) {
        await inscripcionesBoxInstance.put(inscripcion.id, inscripcion);
      }
    }
  }

  static Box<Usuario> get usuariosBoxInstance => Hive.box<Usuario>(usuariosBox);
  static Box<CursoDomain> get cursosBoxInstance => Hive.box<CursoDomain>(cursosBox);
  static Box<Inscripcion> get inscripcionesBoxInstance => Hive.box<Inscripcion>(inscripcionesBox);

  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}