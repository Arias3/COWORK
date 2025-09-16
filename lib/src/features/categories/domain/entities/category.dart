import 'package:hive/hive.dart';
import 'metodo_agrupacion.dart';

part 'category.g.dart';

@HiveType(typeId: 5)
class Category extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int cursoId;

  @HiveField(2)
  String nombre;

  @HiveField(3)
  MetodoAgrupacion metodoAgrupacion;

  @HiveField(4)
  int maxMiembros;

  Category({
    this.id,
    required this.cursoId,
    required this.nombre,
    required this.metodoAgrupacion,
    required this.maxMiembros,
  });

  Category copyWith({
    int? id,
    int? cursoId,
    String? nombre,
    MetodoAgrupacion? metodoAgrupacion,
    int? maxMiembros,
  }) {
    return Category(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      nombre: nombre ?? this.nombre,
      metodoAgrupacion: metodoAgrupacion ?? this.metodoAgrupacion,
      maxMiembros: maxMiembros ?? this.maxMiembros,
    );
  }
}
