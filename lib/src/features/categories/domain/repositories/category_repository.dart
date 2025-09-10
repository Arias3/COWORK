import '../entities/category.dart';

abstract class CategoryRepository {
  Future<int> createCategory(Category category);
  Future<List<Category>> getCategories();
  Future<int> updateCategory(Category category);
  Future<int> deleteCategory(int id);
}
