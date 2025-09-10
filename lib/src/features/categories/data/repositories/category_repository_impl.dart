// import 'package:sqflite/sqflite.dart';
// import '../../../../core/database_helper.dart';
// import '../../domain/entities/category.dart';
// import '../../domain/repositories/category_repository.dart';
// import '../models/category_model.dart';

// class CategoryRepositoryImpl implements CategoryRepository {
//   final dbHelper = DatabaseHelper.instance;

//   @override
//   Future<int> createCategory(Category category) async {
//     final db = await dbHelper.database;
//     return await db.insert("categorias", (category as CategoryModel).toJson());
//   }

//   @override
//   Future<List<Category>> getCategories() async {
//     final db = await dbHelper.database;
//     final result = await db.query("categorias");
//     return result.map((m) => CategoryModel.fromJson(m)).toList();
//   }

//   @override
//   Future<int> updateCategory(Category category) async {
//     final db = await dbHelper.database;
//     return await db.update(
//       "categorias",
//       (category as CategoryModel).toJson(),
//       where: "id = ?",
//       whereArgs: [category.id],
//     );
//   }

//   @override
//   Future<int> deleteCategory(int id) async {
//     final db = await dbHelper.database;
//     return await db.delete("categorias", where: "id = ?", whereArgs: [id]);
//   }
// }
