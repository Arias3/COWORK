import 'package:get/get.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/category_usecases.dart';

class CategoryController extends GetxController {
  final CategoryUseCases useCases;

  CategoryController(this.useCases);

  // Lista reactiva de categorías expuesta a la vista
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

  Future<void> addCategory(Category category) async {
    await useCases.createCategory(category);
    await loadCategories();
  }

  Future<void> editCategory(Category category) async {
    await useCases.updateCategory(category);
    await loadCategories();
  }

  Future<void> removeCategory(int id) async {
    await useCases.deleteCategory(id);
    await loadCategories();
  }
}
