enum CriterioEvaluacion { puntualidad, contribuciones, compromiso, actitud }

extension CriterioEvaluacionExtension on CriterioEvaluacion {
  String get nombre {
    switch (this) {
      case CriterioEvaluacion.puntualidad:
        return 'Puntualidad';
      case CriterioEvaluacion.contribuciones:
        return 'Contribuciones';
      case CriterioEvaluacion.compromiso:
        return 'Compromiso';
      case CriterioEvaluacion.actitud:
        return 'Actitud';
    }
  }

  String get descripcion {
    switch (this) {
      case CriterioEvaluacion.puntualidad:
        return 'Asistencia y cumplimiento de horarios';
      case CriterioEvaluacion.contribuciones:
        return 'Aportes al trabajo del equipo';
      case CriterioEvaluacion.compromiso:
        return 'Dedicación y responsabilidad';
      case CriterioEvaluacion.actitud:
        return 'Comportamiento y colaboración';
    }
  }

  String get key {
    switch (this) {
      case CriterioEvaluacion.puntualidad:
        return 'puntualidad';
      case CriterioEvaluacion.contribuciones:
        return 'contribuciones';
      case CriterioEvaluacion.compromiso:
        return 'compromiso';
      case CriterioEvaluacion.actitud:
        return 'actitud';
    }
  }
}

enum NivelEvaluacion { necesitaMejorar, adecuado, bueno, excelente }

extension NivelEvaluacionExtension on NivelEvaluacion {
  double get calificacion {
    switch (this) {
      case NivelEvaluacion.necesitaMejorar:
        return 2.0;
      case NivelEvaluacion.adecuado:
        return 3.0;
      case NivelEvaluacion.bueno:
        return 4.0;
      case NivelEvaluacion.excelente:
        return 5.0;
    }
  }

  String get nombre {
    switch (this) {
      case NivelEvaluacion.necesitaMejorar:
        return 'Necesita mejorar';
      case NivelEvaluacion.adecuado:
        return 'Adecuado';
      case NivelEvaluacion.bueno:
        return 'Bueno';
      case NivelEvaluacion.excelente:
        return 'Excelente';
    }
  }

  String get descripcion {
    switch (this) {
      case NivelEvaluacion.necesitaMejorar:
        return 'Requiere atención y mejora';
      case NivelEvaluacion.adecuado:
        return 'Cumple con lo mínimo esperado';
      case NivelEvaluacion.bueno:
        return 'Supera las expectativas';
      case NivelEvaluacion.excelente:
        return 'Excepcional desempeño';
    }
  }

  static NivelEvaluacion fromCalificacion(double calificacion) {
    if (calificacion <= 2.5) return NivelEvaluacion.necesitaMejorar;
    if (calificacion <= 3.5) return NivelEvaluacion.adecuado;
    if (calificacion <= 4.5) return NivelEvaluacion.bueno;
    return NivelEvaluacion.excelente;
  }
}
