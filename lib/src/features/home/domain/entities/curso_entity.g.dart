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
      id: fields[0] as int,
      nombre: fields[1] as String,
      descripcion: fields[2] as String,
      codigoRegistro: fields[3] as String,
      profesorId: fields[4] as int?,
      creadoEn: fields[5] as DateTime?,
      categorias: (fields[6] as List).cast<String>(),
      imagen: fields[7] as String?,
      estudiantesNombres: (fields[8] as List).cast<String>(),
      fechaCreacion: fields[9] as DateTime?,
      isOfflineOnly: fields[10] == null ? false : fields[10] as bool,
      lastSyncAttempt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CursoDomain obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.codigoRegistro)
      ..writeByte(4)
      ..write(obj.profesorId)
      ..writeByte(5)
      ..write(obj.creadoEn)
      ..writeByte(6)
      ..write(obj.categorias)
      ..writeByte(7)
      ..write(obj.imagen)
      ..writeByte(8)
      ..write(obj.estudiantesNombres)
      ..writeByte(9)
      ..write(obj.fechaCreacion)
      ..writeByte(10)
      ..write(obj.isOfflineOnly)
      ..writeByte(11)
      ..write(obj.lastSyncAttempt);
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
