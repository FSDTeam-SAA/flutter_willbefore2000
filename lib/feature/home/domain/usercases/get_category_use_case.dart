import '../models/category_model.dart';
import '../repos/categories_repo.dart';

class GetCategoriesUseCase {
  final CategoriesRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<CategoryModel>> call() async {
    return await repository.getCategories();
  }

  Stream<List<CategoryModel>> stream() {
    return repository.getCategoriesStream();
  }
}