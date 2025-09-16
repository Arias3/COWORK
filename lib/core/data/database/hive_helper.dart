import 'package:hive_flutter/hive_flutter.dart';

// entidades
import '../../../src/features/auth/domain/entities/user_entity.dart';
import '../../../src/features/home/domain/entities/curso_entity.dart';
import '../../../src/features/home/domain/entities/inscripcion_entity.dart';
import '../../../src/features/categories/domain/entities/category.dart';
import '../../../src/features/categories/domain/entities/metodo_agrupacion.dart';
import '../../../src/features/activities/domain/models/activity.dart';

class HiveHelper {
  static const String usuariosBox = 'usuarios';
  static const String cursosBox = 'cursos';
  static const String inscripcionesBox = 'inscripciones';
  static const String categoriasBox = 'categorias';
  static const String actividadesBox = 'actividades';

  static Future<void> initHive() async {
    await Hive.initFlutter();

    // ✅ Registrar adapters solo aquí
    Hive.registerAdapter(UsuarioAdapter());
    Hive.registerAdapter(CursoDomainAdapter());
    Hive.registerAdapter(InscripcionAdapter());
    Hive.registerAdapter(MetodoAgrupacionAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(ActivityAdapter());

    // ✅ Abrir boxes solo aquí
    await Hive.openBox<Usuario>(usuariosBox);
    await Hive.openBox<CursoDomain>(cursosBox);
    await Hive.openBox<Inscripcion>(inscripcionesBox);
    await Hive.openBox<Category>(categoriasBox);
    await Hive.openBox<Activity>(actividadesBox);

    // ✅ Cargar datos iniciales
    await _loadInitialData();
  }

  static Future<void> _loadInitialData() async {
    final usuariosBoxInstance = Hive.box<Usuario>(usuariosBox);
    final cursosBoxInstance = Hive.box<CursoDomain>(cursosBox);
    final inscripcionesBoxInstance = Hive.box<Inscripcion>(inscripcionesBox);
    final categoriasBoxInstance = Hive.box<Category>(categoriasBox);
    final actividadesBoxInstance = Hive.box<Activity>(actividadesBox);

    // Usuarios iniciales
    if (usuariosBoxInstance.isEmpty) {
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

    // Cursos iniciales
    if (cursosBoxInstance.isEmpty) {
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

    // Inscripciones iniciales
    if (inscripcionesBoxInstance.isEmpty) {
      final inscripciones = [
        Inscripcion(id: 1, usuarioId: 2, cursoId: 3),
        Inscripcion(id: 2, usuarioId: 3, cursoId: 3),
      ];
      for (var inscripcion in inscripciones) {
        await inscripcionesBoxInstance.put(inscripcion.id, inscripcion);
      }
    }

    // Categorías iniciales
    if (categoriasBoxInstance.isEmpty) {
      final categorias = [
        Category(
          id: 1,
          cursoId: 1,
          nombre: 'Grupo A',
          metodoAgrupacion: MetodoAgrupacion.random,
          maxMiembros: 5,
        ),
        Category(
          id: 2,
          cursoId: 1,
          nombre: 'Grupo B',
          metodoAgrupacion: MetodoAgrupacion.manual,
          maxMiembros: 4,
        ),
      ];
      for (var cat in categorias) {
        await categoriasBoxInstance.put(cat.id, cat);
      }
    }

    // Actividades iniciales
    if (actividadesBoxInstance.isEmpty) {
      final actividades = [
        Activity(
          id: '1',
          categoryId: 1,
          name: 'Tarea Derivadas',
          description: 'Resolver ejercicios de derivadas',
          deliveryDate: DateTime.now().add(const Duration(days: 7)),
        ),
        Activity(
          id: '2',
          categoryId: 2,
          name: 'Exposición',
          description: 'Exposición sobre álgebra',
          deliveryDate: DateTime.now().add(const Duration(days: 14)),
        ),
      ];
      for (var act in actividades) {
        await actividadesBoxInstance.put(act.id, act);
      }
    }
  }

  // ✅ Getters
  static Box<Usuario> get usuariosBoxInstance => Hive.box<Usuario>(usuariosBox);
  static Box<CursoDomain> get cursosBoxInstance => Hive.box<CursoDomain>(cursosBox);
  static Box<Inscripcion> get inscripcionesBoxInstance => Hive.box<Inscripcion>(inscripcionesBox);
  static Box<Category> get categoriasBoxInstance => Hive.box<Category>(categoriasBox);
  static Box<Activity> get actividadesBoxInstance => Hive.box<Activity>(actividadesBox);

  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}
