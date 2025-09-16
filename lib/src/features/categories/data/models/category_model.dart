import '../../domain/entities/category.dart';
import '../../domain/entities/metodo_agrupacion.dart';

class CategoryModel extends Category {
  CategoryModel({
    int? id,
    required int cursoId,
    required String nombre,
    required MetodoAgrupacion metodoAgrupacion,
    required int maxMiembros,
  }) : super(
          id: id,
          cursoId: cursoId,
          nombre: nombre,
          metodoAgrupacion: metodoAgrupacion,
          maxMiembros: maxMiembros,
        );

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      cursoId: json['cursoId'],
      nombre: json['nombre'],
      metodoAgrupacion: MetodoAgrupacion.values.firstWhere(
        (e) => e.toString().split('.').last == json['metodoAgrupacion'],
      ),
      maxMiembros: json['maxMiembros'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cursoId': cursoId,
      'nombre': nombre,
      'metodoAgrupacion': metodoAgrupacion.toString().split('.').last,
      'maxMiembros': maxMiembros,
    };
  }
}
