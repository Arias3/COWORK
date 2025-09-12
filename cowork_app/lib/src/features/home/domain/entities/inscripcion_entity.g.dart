// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inscripcion_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InscripcionAdapter extends TypeAdapter<Inscripcion> {
  @override
  final int typeId = 2;

  @override
  Inscripcion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Inscripcion(
      id: fields[0] as int?,
      usuarioId: fields[1] as int,
      cursoId: fields[2] as int,
      fechaInscripcion: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Inscripcion obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.usuarioId)
      ..writeByte(2)
      ..write(obj.cursoId)
      ..writeByte(3)
      ..write(obj.fechaInscripcion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InscripcionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
