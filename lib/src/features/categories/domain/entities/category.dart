enum MetodoAgrupacion { random, selfAssigned, manual }

class Category {
  final int? id;
  final int cursoId;
  final String nombre;
  final MetodoAgrupacion metodoAgrupacion;
  final int maxMiembros;

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
