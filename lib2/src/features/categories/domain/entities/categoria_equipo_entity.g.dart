// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categoria_equipo_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoriaEquipoAdapter extends TypeAdapter<CategoriaEquipo> {
  @override
  final int typeId = 3;

  @override
  CategoriaEquipo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoriaEquipo(
      id: fields[0] as int?,
      nombre: fields[1] as String,
      cursoId: fields[2] as int,
      tipoAsignacion: fields[3] as TipoAsignacion,
      maxEstudiantesPorEquipo: fields[4] as int,
      equiposIds: (fields[5] as List).cast<int>(),
      creadoEn: fields[6] as DateTime?,
      equiposGenerados: fields[7] as bool,
      descripcion: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CategoriaEquipo obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.cursoId)
      ..writeByte(3)
      ..write(obj.tipoAsignacion)
      ..writeByte(4)
      ..write(obj.maxEstudiantesPorEquipo)
      ..writeByte(5)
      ..write(obj.equiposIds)
      ..writeByte(6)
      ..write(obj.creadoEn)
      ..writeByte(7)
      ..write(obj.equiposGenerados)
      ..writeByte(8)
      ..write(obj.descripcion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriaEquipoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
