// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metodo_agrupacion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MetodoAgrupacionAdapter extends TypeAdapter<MetodoAgrupacion> {
  @override
  final int typeId = 4;

  @override
  MetodoAgrupacion read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MetodoAgrupacion.random;
      case 1:
        return MetodoAgrupacion.selfAssigned;
      case 2:
        return MetodoAgrupacion.manual;
      default:
        return MetodoAgrupacion.random;
    }
  }

  @override
  void write(BinaryWriter writer, MetodoAgrupacion obj) {
    switch (obj) {
      case MetodoAgrupacion.random:
        writer.writeByte(0);
        break;
      case MetodoAgrupacion.selfAssigned:
        writer.writeByte(1);
        break;
      case MetodoAgrupacion.manual:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetodoAgrupacionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
