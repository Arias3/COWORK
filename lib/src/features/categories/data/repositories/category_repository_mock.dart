// lib/features/categories/data/repositories/category_repository_mock.dart
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryMock implements CategoryRepository {
  final List<Category> _categories = [];

  @override
  Future<List<Category>> getCategories() async => _categories;

  @override
  Future<int> createCategory(Category category) async {
    final newCategory = category.copyWith(id: _categories.length + 1);
    _categories.add(newCategory);
    return newCategory.id!;
  }

  @override
  Future<int> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      return 1; // éxito
    }
    return 0; // no encontrado
  }

  @override
  Future<int> deleteCategory(int id) async {
    final before = _categories.length;
    _categories.removeWhere((c) => c.id == id);
    return before - _categories.length;
  }
}
