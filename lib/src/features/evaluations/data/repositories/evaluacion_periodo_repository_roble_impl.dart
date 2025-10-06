import '../../domain/entities/evaluacion_periodo.dart';
import '../../domain/repositories/evaluacion_periodo_repository.dart';
import '../models/roble_evaluacion_periodo_dto.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';
import 'dart:convert';

class EvaluacionPeriodoRepositoryRobleImpl
    implements EvaluacionPeriodoRepository {
  final RobleApiDataSource _dataSource;

  EvaluacionPeriodoRepositoryRobleImpl(this._dataSource);

  // Generar ID consistente
  String _generateConsistentId(Map<String, dynamic> data) {
    final String baseString =
        '${data['actividadId']}_${data['titulo']}_${data['fechaCreacion']}';
    final bytes = utf8.encode(baseString);
    return bytes
        .fold(0, (prev, element) => prev + element)
        .toString()
        .padLeft(12, '0');
  }

  @override
  Future<List<EvaluacionPeriodo>> getEvaluacionesPorActividad(
    String actividadId,
  ) async {
    try {
      final response = await _dataSource.read(
        'EvaluacionPeriodo',
        filters: {'actividadId': actividadId},
      );

      return response
          .map((json) => RobleEvaluacionPeriodoDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error al obtener evaluaciones por actividad: $e');
      return [];
    }
  }

  @override
  Future<List<EvaluacionPeriodo>> getEvaluacionesPorProfesor(
    String profesorId,
  ) async {
    try {
      final response = await _dataSource.read(
        'EvaluacionPeriodo',
        filters: {'profesorId': profesorId},
      );

      return response
          .map((json) => RobleEvaluacionPeriodoDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error al obtener evaluaciones por profesor: $e');
      return [];
    }
  }

  @override
  Future<EvaluacionPeriodo?> getEvaluacionPeriodoById(String id) async {
    try {
      final response = await _dataSource.getById('EvaluacionPeriodo', id);

      if (response != null) {
        return RobleEvaluacionPeriodoDto.fromJson(response).toEntity();
      }
      return null;
    } catch (e) {
      print('Error al obtener evaluación por ID: $e');
      return null;
    }
  }

  @override
  Future<EvaluacionPeriodo> crearEvaluacionPeriodo(
    EvaluacionPeriodo evaluacion,
  ) async {
    try {
      final dto = RobleEvaluacionPeriodoDto.fromEntity(evaluacion);
      final data = dto.toJson();

      // Generar ID consistente si no existe
      if (evaluacion.id.isEmpty) {
        data['_id'] = _generateConsistentId(data);
      } else {
        data['_id'] = evaluacion.id;
      }

      final response = await _dataSource.create('EvaluacionPeriodo', data);
      return RobleEvaluacionPeriodoDto.fromJson(response).toEntity();
    } catch (e) {
      print('Error al crear evaluación periodo: $e');
      rethrow;
    }
  }

  @override
  Future<EvaluacionPeriodo> actualizarEvaluacionPeriodo(
    EvaluacionPeriodo evaluacion,
  ) async {
    try {
      final dto = RobleEvaluacionPeriodoDto.fromEntity(
        evaluacion.copyWith(fechaActualizacion: DateTime.now()),
      );
      final data = dto.toJson();

      final response = await _dataSource.update(
        'EvaluacionPeriodo',
        evaluacion.id,
        data,
      );

      // Obtener el registro actualizado
      final updatedRecord = await _dataSource.getById(
        'EvaluacionPeriodo',
        evaluacion.id,
      );
      if (updatedRecord != null) {
        return RobleEvaluacionPeriodoDto.fromJson(updatedRecord).toEntity();
      }

      throw Exception('No se pudo actualizar la evaluación periodo');
    } catch (e) {
      print('Error al actualizar evaluación periodo: $e');
      rethrow;
    }
  }

  @override
  Future<bool> eliminarEvaluacionPeriodo(String id) async {
    try {
      await _dataSource.delete('EvaluacionPeriodo', id);
      return true;
    } catch (e) {
      print('Error al eliminar evaluación periodo: $e');
      return false;
    }
  }

  @override
  Future<List<EvaluacionPeriodo>> getEvaluacionesActivas() async {
    try {
      final response = await _dataSource.read(
        'EvaluacionPeriodo',
        filters: {'estado': 'activo'},
      );

      return response
          .map((json) => RobleEvaluacionPeriodoDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error al obtener evaluaciones activas: $e');
      return [];
    }
  }

  @override
  Future<List<EvaluacionPeriodo>> getEvaluacionesPorEstado(
    EstadoEvaluacionPeriodo estado,
  ) async {
    try {
      final response = await _dataSource.read(
        'EvaluacionPeriodo',
        filters: {'estado': estado.name},
      );

      return response
          .map((json) => RobleEvaluacionPeriodoDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error al obtener evaluaciones por estado: $e');
      return [];
    }
  }
}
