import '../entities/category.dart';

abstract class CategoryRepository {
  Future<int> createCategory(Category category);
  Future<List<Category>> getCategories();
  Future<bool> updateCategory(Category category);
  Future<bool> deleteCategory(int id);
  Future<List<Category>> getCategoriesByCurso(int cursoId);
}
