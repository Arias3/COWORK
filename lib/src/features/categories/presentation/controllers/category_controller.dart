import 'package:get/get.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/category_usecases.dart';

class CategoryController extends GetxController {
  final CategoryUseCases useCases;

  CategoryController(this.useCases);

  final categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final result = await useCases.getCategories();
    categories.assignAll(result);
  }

  Future<void> loadCategoriesByCurso(int cursoId) async {
    final result = await useCases.getCategoriesByCurso(cursoId);
    categories.assignAll(result);
  }

  // 🔹 ahora retorna int en vez de void
  Future<int> addCategory(Category category) async {
    final id = await useCases.createCategory(category);
    if (id > 0) {
      await loadCategoriesByCurso(category.cursoId);
    }
    return id;
  }

  Future<bool> removeCategory(int id) async {
    final result = await useCases.deleteCategory(id);
    if (result) {
      await loadCategories();
    }
    return result;
  }

  Future<bool> editCategory(Category category) async {
    final result = await useCases.updateCategory(category);
    if (result) {
      await loadCategoriesByCurso(category.cursoId);
    }
    return result;
  }
}
