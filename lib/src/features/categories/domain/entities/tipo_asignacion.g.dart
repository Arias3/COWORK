// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipo_asignacion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TipoAsignacionAdapter extends TypeAdapter<TipoAsignacion> {
  @override
  final int typeId = 5;

  @override
  TipoAsignacion read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipoAsignacion.manual;
      case 1:
        return TipoAsignacion.aleatoria;
      default:
        return TipoAsignacion.manual;
    }
  }

  @override
  void write(BinaryWriter writer, TipoAsignacion obj) {
    switch (obj) {
      case TipoAsignacion.manual:
        writer.writeByte(0);
        break;
      case TipoAsignacion.aleatoria:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipoAsignacionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
