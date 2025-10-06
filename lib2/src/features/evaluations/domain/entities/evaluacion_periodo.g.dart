// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluacion_periodo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EvaluacionPeriodoAdapter extends TypeAdapter<EvaluacionPeriodo> {
  @override
  final int typeId = 10;

  @override
  EvaluacionPeriodo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EvaluacionPeriodo(
      id: fields[0] as String,
      actividadId: fields[1] as String,
      titulo: fields[2] as String,
      descripcion: fields[3] as String?,
      fechaInicio: fields[4] as DateTime,
      fechaFin: fields[5] as DateTime?,
      fechaCreacion: fields[6] as DateTime,
      profesorId: fields[7] as String,
      estado: fields[8] as EstadoEvaluacionPeriodo,
      permitirAutoEvaluacion: fields[9] as bool,
      duracionMaximaHoras: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, EvaluacionPeriodo obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.actividadId)
      ..writeByte(2)
      ..write(obj.titulo)
      ..writeByte(3)
      ..write(obj.descripcion)
      ..writeByte(4)
      ..write(obj.fechaInicio)
      ..writeByte(5)
      ..write(obj.fechaFin)
      ..writeByte(6)
      ..write(obj.fechaCreacion)
      ..writeByte(7)
      ..write(obj.profesorId)
      ..writeByte(8)
      ..write(obj.estado)
      ..writeByte(9)
      ..write(obj.permitirAutoEvaluacion)
      ..writeByte(10)
      ..write(obj.duracionMaximaHoras);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluacionPeriodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EstadoEvaluacionPeriodoAdapter
    extends TypeAdapter<EstadoEvaluacionPeriodo> {
  @override
  final int typeId = 11;

  @override
  EstadoEvaluacionPeriodo read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EstadoEvaluacionPeriodo.pendiente;
      case 1:
        return EstadoEvaluacionPeriodo.activo;
      case 2:
        return EstadoEvaluacionPeriodo.finalizado;
      default:
        return EstadoEvaluacionPeriodo.pendiente;
    }
  }

  @override
  void write(BinaryWriter writer, EstadoEvaluacionPeriodo obj) {
    switch (obj) {
      case EstadoEvaluacionPeriodo.pendiente:
        writer.writeByte(0);
        break;
      case EstadoEvaluacionPeriodo.activo:
        writer.writeByte(1);
        break;
      case EstadoEvaluacionPeriodo.finalizado:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EstadoEvaluacionPeriodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
