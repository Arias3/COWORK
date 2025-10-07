// // GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'activity.dart';

// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************

// class ActivityAdapter extends TypeAdapter<Activity> {
//   @override
//   final int typeId = 6;

//   @override
//   Activity read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return Activity(
//       id: fields[0] as String?,
//       categoryId: fields[1] as int,
//       name: fields[2] as String,
//       description: fields[3] as String,
//       deliveryDate: fields[4] as DateTime,
//     );
//   }

//   @override
//   void write(BinaryWriter writer, Activity obj) {
//     writer
//       ..writeByte(5)
//       ..writeByte(0)
//       ..write(obj.id)
//       ..writeByte(1)
//       ..write(obj.categoryId)
//       ..writeByte(2)
//       ..write(obj.name)
//       ..writeByte(3)
//       ..write(obj.description)
//       ..writeByte(4)
//       ..write(obj.deliveryDate);
//   }

//   @override
//   int get hashCode => typeId.hashCode;

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is ActivityAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
