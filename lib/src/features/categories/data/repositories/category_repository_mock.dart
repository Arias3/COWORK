// lib/features/categories/data/repositories/category_repository_mock.dart
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryMock implements CategoryRepository {
  final List<Category> _categories = [];
  int _idCounter = 0;

  @override
  Future<List<Category>> getCategories() async {
    return List.unmodifiable(_categories);
  }

  @override
  Future<int> createCategory(Category category) async {
    _idCounter++;
    final newCategory = category.copyWith(id: _idCounter);
    _categories.add(newCategory);
    return newCategory.id!;
  }

  @override
  Future<bool> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteCategory(int id) async {
    final before = _categories.length;
    _categories.removeWhere((c) => c.id == id);
    return _categories.length < before;
  }

  /// 🔹 Nuevo método para cumplir la interfaz
  @override
  Future<List<Category>> getCategoriesByCurso(int cursoId) async {
    // aquí asumo que Category tiene un campo cursoId
    return _categories.where((c) => c.cursoId == cursoId).toList();
  }
}
