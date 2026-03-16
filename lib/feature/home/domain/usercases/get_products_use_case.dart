import '../../../product/domain/entrity/product.dart';
import '../../../product/domain/repos/product_repository.dart';

class GetProductsUseCase {
  final ProductsRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<Product>> call() async {
    return await repository.getAllProducts();
  }
}

class GetActiveProductsUseCase {
  final ProductsRepository _repository;

  GetActiveProductsUseCase(this._repository);

  Future<List<Product>> call() async {
    return await _repository.getActiveProducts();
  }
}

class GetProductsByCategoryUseCase {
  final ProductsRepository _repository;

  GetProductsByCategoryUseCase(this._repository);

  Future<List<Product>> call(String categoryId) async {
    return await _repository.getProductsByCategory(categoryId);
  }
}

class GetProductsByPromoUseCase {
  final ProductsRepository _repository;

  GetProductsByPromoUseCase(this._repository);

  Future<List<Product>> call(String promoId) async {
    return await _repository.getProductsByPromo(promoId);
  }
}

class GetProductByIdUseCase {
  final ProductsRepository _repository;

  GetProductByIdUseCase(this._repository);

  Future<Product?> call(String id) async {
    return await _repository.getProductById(id);
  }
}

class SearchProductsUseCase {
  final ProductsRepository _repository;

  SearchProductsUseCase(this._repository);

  Future<List<Product>> call(String query) async {
    return await _repository.searchProducts(query);
  }
}
