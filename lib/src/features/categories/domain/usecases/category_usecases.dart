import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CreateCategory {
  final CategoryRepository repository;
  CreateCategory(this.repository);

  Future<int> call(Category category) => repository.createCategory(category);
}

class GetCategories {
  final CategoryRepository repository;
  GetCategories(this.repository);

  Future<List<Category>> call() => repository.getCategories();
}

class UpdateCategory {
  final CategoryRepository repository;
  UpdateCategory(this.repository);

  Future<int> call(Category category) => repository.updateCategory(category);
}

class DeleteCategory {
  final CategoryRepository repository;
  DeleteCategory(this.repository);

  Future<int> call(int id) => repository.deleteCategory(id);
}

/// 🔹 Agregador de todos los casos de uso
class CategoryUseCases {
  final CreateCategory createCategory;
  final GetCategories getCategories;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;

  CategoryUseCases({
    required this.createCategory,
    required this.getCategories,
    required this.updateCategory,
    required this.deleteCategory,
  });
}
