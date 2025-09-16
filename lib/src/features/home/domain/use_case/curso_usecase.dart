import '../entities/curso_entity.dart';
import '../repositories/curso_repository.dart';
import '../repositories/inscripcion_repository.dart';
import '../entities/inscripcion_entity.dart';

class CursoUseCase {
  final CursoRepository _cursoRepository;
  final InscripcionRepository _inscripcionRepository;

  CursoUseCase(this._cursoRepository, this._inscripcionRepository);

  Future<List<CursoDomain>> getCursos() => _cursoRepository.getCursos();
  Future<List<CursoDomain>> getCursosPorProfesor(int profesorId) => 
      _cursoRepository.getCursosPorProfesor(profesorId);
  
  Future<List<CursoDomain>> getCursosInscritos(int usuarioId) => 
      _cursoRepository.getCursosInscritos(usuarioId);

  Future<CursoDomain?> getCursoById(int id) => _cursoRepository.getCursoById(id);
  Future<CursoDomain?> getCursoByCodigoRegistro(String codigo) => 
      _cursoRepository.getCursoByCodigoRegistro(codigo);

  Future<int> createCurso({
    required String nombre,
    required String descripcion,
    required int profesorId,
    String? imagen,
    List<String>? categorias,
    List<String>? estudiantesNombres,
  }) async {
    // Validaciones
    if (nombre.trim().isEmpty) throw Exception('El nombre del curso es obligatorio');
    if (descripcion.trim().isEmpty) throw Exception('La descripción es obligatoria');

    // Generar código de registro único
    final codigoRegistro = _generateCourseCode(nombre);

    final curso = CursoDomain(
      nombre: nombre.trim(),
      descripcion: descripcion.trim(),
      profesorId: profesorId,
      codigoRegistro: codigoRegistro,
      imagen: imagen ?? 'assets/images/default_course.png',
      categorias: categorias ?? [],
      estudiantesNombres: estudiantesNombres ?? [],
    );

    return await _cursoRepository.createCurso(curso);
  }

  Future<void> updateCurso(CursoDomain curso) => _cursoRepository.updateCurso(curso);
  Future<void> deleteCurso(int id) => _cursoRepository.deleteCurso(id);

  Future<void> inscribirseEnCurso(int usuarioId, String codigoRegistro) async {
    final curso = await _cursoRepository.getCursoByCodigoRegistro(codigoRegistro);
    if (curso == null) {
      throw Exception('Código de curso no válido');
    }

    final yaInscrito = await _inscripcionRepository.estaInscrito(usuarioId, curso.id!);
    if (yaInscrito) {
      throw Exception('Ya estás inscrito en este curso');
    }

    final inscripcion = Inscripcion(
      usuarioId: usuarioId,
      cursoId: curso.id!,
    );

    await _inscripcionRepository.createInscripcion(inscripcion);
  }

  String _generateCourseCode(String nombre) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final nameCode = nombre.replaceAll(' ', '').toUpperCase().substring(0, 3);
    return '$nameCode$timestamp';
  }
}