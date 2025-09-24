// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluacion_individual.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EvaluacionIndividualAdapter extends TypeAdapter<EvaluacionIndividual> {
  @override
  final int typeId = 9;

  @override
  EvaluacionIndividual read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EvaluacionIndividual(
      id: fields[0] as String,
      evaluacionPeriodoId: fields[1] as String,
      evaluadorId: fields[2] as String,
      evaluadoId: fields[3] as String,
      equipoId: fields[4] as String,
      calificaciones: (fields[5] as Map).cast<String, double>(),
      comentarios: fields[6] as String?,
      fechaCreacion: fields[7] as DateTime,
      fechaActualizacion: fields[8] as DateTime?,
      completada: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EvaluacionIndividual obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.evaluacionPeriodoId)
      ..writeByte(2)
      ..write(obj.evaluadorId)
      ..writeByte(3)
      ..write(obj.evaluadoId)
      ..writeByte(4)
      ..write(obj.equipoId)
      ..writeByte(5)
      ..write(obj.calificaciones)
      ..writeByte(6)
      ..write(obj.comentarios)
      ..writeByte(7)
      ..write(obj.fechaCreacion)
      ..writeByte(8)
      ..write(obj.fechaActualizacion)
      ..writeByte(9)
      ..write(obj.completada);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluacionIndividualAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
