// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipo_actividad_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EquipoActividadAdapter extends TypeAdapter<EquipoActividad> {
  @override
  final int typeId = 8;

  @override
  EquipoActividad read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EquipoActividad(
      id: fields[0] as int?,
      equipoId: fields[1] as int,
      actividadId: fields[2] as String,
      asignadoEn: fields[3] as DateTime?,
      fechaEntrega: fields[4] as DateTime?,
      estado: fields[5] as String?,
      comentarioProfesor: fields[6] as String?,
      calificacion: fields[7] as double?,
      fechaCompletada: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, EquipoActividad obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.equipoId)
      ..writeByte(2)
      ..write(obj.actividadId)
      ..writeByte(3)
      ..write(obj.asignadoEn)
      ..writeByte(4)
      ..write(obj.fechaEntrega)
      ..writeByte(5)
      ..write(obj.estado)
      ..writeByte(6)
      ..write(obj.comentarioProfesor)
      ..writeByte(7)
      ..write(obj.calificacion)
      ..writeByte(8)
      ..write(obj.fechaCompletada);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipoActividadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
