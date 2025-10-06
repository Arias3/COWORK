import '../../domain/entities/evaluacion_individual.dart';
import '../../domain/repositories/evaluacion_individual_repository.dart';
import '../models/roble_evaluacion_individual_dto.dart';
import '../../../../../core/data/datasources/roble_api_datasource.dart';

class EvaluacionIndividualRepositoryRobleImpl
    implements EvaluacionIndividualRepository {
  final RobleApiDataSource _dataSource;

  EvaluacionIndividualRepositoryRobleImpl(this._dataSource);

  @override
  Future<List<EvaluacionIndividual>> getEvaluacionesPorPeriodo(
    String evaluacionPeriodoId,
  ) async {
    try {
      print(
        '🔍 [EVAL-REPO] Buscando evaluaciones para periodo: $evaluacionPeriodoId',
      );

      final response = await _dataSource.read(
        'EvaluacionIndividual',
        filters: {'evaluacionPeriodoId': evaluacionPeriodoId},
      );

      print('📊 [EVAL-REPO] Respuesta recibida: ${response.length} registros');

      if (response.isEmpty) {
        print('📝 [EVAL-REPO] No se encontraron evaluaciones para el periodo');
        return [];
      }

      final List<EvaluacionIndividual> evaluaciones = [];

      for (int i = 0; i < response.length; i++) {
        try {
          final item = response[i];
          print('🔍 [EVAL-REPO] Procesando registro $i: ${item.runtimeType}');
          print('🔍 [EVAL-REPO] Contenido del registro: $item');

          final dto = RobleEvaluacionIndividualDto.fromJson(item);
          evaluaciones.add(dto.toEntity());
          print('✅ [EVAL-REPO] Evaluación $i procesada correctamente');
        } catch (e) {
          print('❌ [EVAL-REPO] Error procesando registro $i: $e');
          print(
            '🔍 [EVAL-REPO] Datos del registro problemático: ${response[i]}',
          );
        }
      }

      print(
        '✅ [EVAL-REPO] Total evaluaciones procesadas: ${evaluaciones.length}',
      );
      return evaluaciones;
    } catch (e) {
      print('❌ [EVAL-REPO] Error al obtener evaluaciones por período: $e');
      return [];
    }
  }

  @override
  Future<List<EvaluacionIndividual>> getEvaluacionesPorEvaluador(
    String evaluadorId,
  ) async {
    try {
      final response = await _dataSource.read(
        'EvaluacionIndividual',
        filters: {'evaluadorId': evaluadorId},
      );

      return response
          .map((json) => RobleEvaluacionIndividualDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error al obtener evaluaciones por evaluador: $e');
      return [];
    }
  }

  @override
  Future<List<EvaluacionIndividual>> getEvaluacionesPorEvaluado(
    String evaluadoId,
  ) async {
    try {
      final response = await _dataSource.read(
        'EvaluacionIndividual',
        filters: {'evaluadoId': evaluadoId},
      );

      return response
          .map((json) => RobleEvaluacionIndividualDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error al obtener evaluaciones por evaluado: $e');
      return [];
    }
  }

  @override
  Future<List<EvaluacionIndividual>> getEvaluacionesPorEquipo(
    String equipoId,
  ) async {
    try {
      final response = await _dataSource.read(
        'EvaluacionIndividual',
        filters: {'equipoId': equipoId},
      );

      return response
          .map((json) => RobleEvaluacionIndividualDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error al obtener evaluaciones por equipo: $e');
      return [];
    }
  }

  @override
  Future<EvaluacionIndividual?> getEvaluacionById(String id) async {
    try {
      final response = await _dataSource.getById('EvaluacionIndividual', id);

      if (response != null) {
        return RobleEvaluacionIndividualDto.fromJson(response).toEntity();
      }
      return null;
    } catch (e) {
      print('Error al obtener evaluación por ID: $e');
      return null;
    }
  }

  @override
  Future<EvaluacionIndividual?> getEvaluacionEspecifica(
    String evaluacionPeriodoId,
    String evaluadorId,
    String evaluadoId,
  ) async {
    try {
      print('🔍 [EVAL-REPO] Buscando evaluación específica:');
      print('  - Periodo: $evaluacionPeriodoId');
      print('  - Evaluador: $evaluadorId');
      print('  - Evaluado: $evaluadoId');

      final response = await _dataSource.read(
        'EvaluacionIndividual',
        filters: {
          'evaluacionPeriodoId': evaluacionPeriodoId,
          'evaluadorId': evaluadorId,
          'evaluadoId': evaluadoId,
        },
      );

      print(
        '📊 [EVAL-REPO] Respuesta evaluación específica: ${response.length} registros',
      );

      if (response.isNotEmpty) {
        try {
          final item = response[0];
          print('🔍 [EVAL-REPO] Tipo de dato recibido: ${item.runtimeType}');
          print('🔍 [EVAL-REPO] Contenido del registro: $item');

          final dto = RobleEvaluacionIndividualDto.fromJson(item);
          print('✅ [EVAL-REPO] Evaluación específica encontrada');
          return dto.toEntity();
        } catch (e) {
          print('❌ [EVAL-REPO] Error procesando evaluación específica: $e');
          print('🔍 [EVAL-REPO] Datos problemáticos: ${response[0]}');
          return null;
        }
      }

      print('📝 [EVAL-REPO] No se encontró evaluación específica');
      return null;
    } catch (e) {
      print('❌ [EVAL-REPO] Error al obtener evaluación específica: $e');
      return null;
    }
  }

  @override
  Future<EvaluacionIndividual> crearEvaluacion(
    EvaluacionIndividual evaluacion,
  ) async {
    try {
      print('🔄 [EVAL-REPO] Creando evaluación...');
      print('🔄 [EVAL-REPO] Periodo: ${evaluacion.evaluacionPeriodoId}');
      print('🔄 [EVAL-REPO] Evaluador: ${evaluacion.evaluadorId}');
      print('🔄 [EVAL-REPO] Evaluado: ${evaluacion.evaluadoId}');

      final dto = RobleEvaluacionIndividualDto.fromEntity(evaluacion);
      final data = dto.toJson();

      // Generar ID único válido para Roble (12 caracteres alfanuméricos)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final id = _generateRobleId(timestamp.toString());

      data['_id'] = id;

      print('🆔 [EVAL-REPO] ID generado: $id (longitud: ${id.length})');
      print('📦 [EVAL-REPO] Datos a enviar: $data');

      final response = await _dataSource.create('EvaluacionIndividual', data);

      print('✅ [EVAL-REPO] Respuesta recibida: $response');

      return RobleEvaluacionIndividualDto.fromJson(response).toEntity();
    } catch (e) {
      print('❌ [EVAL-REPO] Error al crear evaluación individual: $e');
      rethrow;
    }
  }

  /// Genera un ID válido para Roble (exactamente 12 caracteres alfanuméricos)
  String _generateRobleId(String seed) {
    // Usar timestamp y microsegundos para generar un ID único
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final microsecond = DateTime.now().microsecond.toString();

    // Combinar y tomar solo caracteres alfanuméricos
    final combined = timestamp + microsecond + seed;
    final alphanumeric = combined.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // Asegurar exactamente 12 caracteres
    if (alphanumeric.length >= 12) {
      return alphanumeric.substring(0, 12);
    } else {
      // Rellenar con caracteres predeterminados si es necesario
      return alphanumeric.padRight(12, '0');
    }
  }

  @override
  Future<EvaluacionIndividual> actualizarEvaluacion(
    EvaluacionIndividual evaluacion,
  ) async {
    try {
      final dto = RobleEvaluacionIndividualDto.fromEntity(
        evaluacion.copyWith(fechaActualizacion: DateTime.now()),
      );
      final data = dto.toJson();

      await _dataSource.update('EvaluacionIndividual', evaluacion.id, data);

      // Obtener el registro actualizado
      final updatedRecord = await _dataSource.getById(
        'EvaluacionIndividual',
        evaluacion.id,
      );
      if (updatedRecord != null) {
        return RobleEvaluacionIndividualDto.fromJson(updatedRecord).toEntity();
      }

      throw Exception('No se pudo actualizar la evaluación individual');
    } catch (e) {
      print('Error al actualizar evaluación individual: $e');
      rethrow;
    }
  }

  @override
  Future<bool> eliminarEvaluacion(String id) async {
    try {
      await _dataSource.delete('EvaluacionIndividual', id);
      return true;
    } catch (e) {
      print('Error al eliminar evaluación individual: $e');
      return false;
    }
  }

  @override
  Future<List<EvaluacionIndividual>> getEvaluacionesCompletadas(
    String evaluacionPeriodoId,
  ) async {
    try {
      final response = await _dataSource.read(
        'EvaluacionIndividual',
        filters: {
          'evaluacionPeriodoId': evaluacionPeriodoId,
          'completada': true,
        },
      );

      return response
          .map((json) => RobleEvaluacionIndividualDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error al obtener evaluaciones completadas: $e');
      return [];
    }
  }

  @override
  Future<List<EvaluacionIndividual>> getEvaluacionesPendientes(
    String evaluadorId,
    String evaluacionPeriodoId,
  ) async {
    try {
      final response = await _dataSource.read(
        'EvaluacionIndividual',
        filters: {
          'evaluadorId': evaluadorId,
          'evaluacionPeriodoId': evaluacionPeriodoId,
          'completada': false,
        },
      );

      return response
          .map((json) => RobleEvaluacionIndividualDto.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      print('Error al obtener evaluaciones pendientes: $e');
      return [];
    }
  }

  @override
  Future<Map<String, double>> getPromedioEvaluacionesPorUsuario(
    String evaluadoId,
    String evaluacionPeriodoId,
  ) async {
    try {
      final evaluaciones = await getEvaluacionesPorPeriodo(evaluacionPeriodoId);
      final evaluacionesDelUsuario = evaluaciones
          .where((eval) => eval.evaluadoId == evaluadoId && eval.completada)
          .toList();

      if (evaluacionesDelUsuario.isEmpty) {
        return {};
      }

      Map<String, List<double>> calificacionesPorCriterio = {};

      for (final evaluacion in evaluacionesDelUsuario) {
        evaluacion.calificaciones.forEach((criterio, calificacion) {
          if (!calificacionesPorCriterio.containsKey(criterio)) {
            calificacionesPorCriterio[criterio] = [];
          }
          calificacionesPorCriterio[criterio]!.add(calificacion);
        });
      }

      Map<String, double> promedios = {};
      calificacionesPorCriterio.forEach((criterio, calificaciones) {
        final promedio =
            calificaciones.reduce((a, b) => a + b) / calificaciones.length;
        promedios[criterio] = promedio;
      });

      return promedios;
    } catch (e) {
      print('Error al calcular promedios: $e');
      return {};
    }
  }
}
