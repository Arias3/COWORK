import 'package:hive/hive.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class HiveCategoryRepository implements CategoryRepository {
  final Box<Category> _box;

  HiveCategoryRepository(this._box);

  @override
  Future<int> createCategory(Category category) async {
    final newId = category.id ?? DateTime.now().millisecondsSinceEpoch;
    final newCategory = category.copyWith(id: newId);
    await _box.put(newId, newCategory);
    return newId;
  }

  @override
  Future<List<Category>> getCategories() async {
    return _box.values.toList();
  }

  @override
  Future<List<Category>> getCategoriesByCurso(int cursoId) async {
    return _box.values.where((c) => c.cursoId == cursoId).toList();
  }

  @override
  Future<bool> updateCategory(Category category) async {
    if (category.id == null) return false;
    if (!_box.containsKey(category.id)) return false;
    await _box.put(category.id, category);
    return true;
  }

  @override
  Future<bool> deleteCategory(int id) async {
    if (!_box.containsKey(id)) return false;
    await _box.delete(id);
    return true;
  }
}
