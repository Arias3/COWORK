// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipo_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EquipoAdapter extends TypeAdapter<Equipo> {
  @override
  final int typeId = 4;

  @override
  Equipo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Equipo(
      id: fields[0] as int?,
      nombre: fields[1] as String,
      categoriaId: fields[2] as int,
      estudiantesIds: (fields[3] as List).cast<int>(),
      creadoEn: fields[4] as DateTime?,
      descripcion: fields[5] as String?,
      color: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Equipo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.categoriaId)
      ..writeByte(3)
      ..write(obj.estudiantesIds)
      ..writeByte(4)
      ..write(obj.creadoEn)
      ..writeByte(5)
      ..write(obj.descripcion)
      ..writeByte(6)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
