import 'package:hive/hive.dart';
part 'tipo_asignacion.g.dart';

@HiveType(typeId: 5)
enum TipoAsignacion {
  @HiveField(0)
  manual,
  @HiveField(1)
  aleatoria,
}