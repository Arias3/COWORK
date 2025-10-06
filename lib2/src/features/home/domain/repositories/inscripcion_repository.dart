import '../entities/inscripcion_entity.dart';

abstract class InscripcionRepository {
  Future<List<Inscripcion>> getInscripciones();
  Future<List<Inscripcion>> getInscripcionesPorUsuario(int usuarioId);
  Future<List<Inscripcion>> getInscripcionesPorCurso(int cursoId);
  Future<Inscripcion?> getInscripcion(int usuarioId, int cursoId);
  Future<int> createInscripcion(Inscripcion inscripcion);
  Future<void> deleteInscripcion(int usuarioId, int cursoId);
  Future<bool> estaInscrito(int usuarioId, int cursoId);
}