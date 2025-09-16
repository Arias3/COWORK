import 'package:hive/hive.dart';

part 'metodo_agrupacion.g.dart';

@HiveType(typeId: 4) // usa un ID único
enum MetodoAgrupacion {
  @HiveField(0)
  random,

  @HiveField(1)
  selfAssigned,

  @HiveField(2)
  manual,
}
