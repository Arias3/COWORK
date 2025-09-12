// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curso_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CursoDomainAdapter extends TypeAdapter<CursoDomain> {
  @override
  final int typeId = 1;

  @override
  CursoDomain read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CursoDomain(
      id: fields[0] as int?,
      nombre: fields[1] as String,
      descripcion: fields[2] as String,
      profesorId: fields[3] as int,
      codigoRegistro: fields[4] as String,
      creadoEn: fields[5] as DateTime?,
      categorias: (fields[6] as List).cast<String>(),
      imagen: fields[7] as String,
      estudiantesNombres: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CursoDomain obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.profesorId)
      ..writeByte(4)
      ..write(obj.codigoRegistro)
      ..writeByte(5)
      ..write(obj.creadoEn)
      ..writeByte(6)
      ..write(obj.categorias)
      ..writeByte(7)
      ..write(obj.imagen)
      ..writeByte(8)
      ..write(obj.estudiantesNombres);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CursoDomainAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
