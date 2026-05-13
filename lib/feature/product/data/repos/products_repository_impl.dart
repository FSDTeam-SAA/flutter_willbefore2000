import '../../domain/entrity/product.dart';
import '../../domain/repos/product_repository.dart';

import '../sources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remoteDataSource;

  ProductsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final productModels = await _remoteDataSource.getAllProducts();
      return productModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final productModels = await _remoteDataSource.getProductsByCategory(
        categoryId,
      );
      return productModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByPromo(String promoId) async {
    try {
      final productModels = await _remoteDataSource.getProductsByPromo(promoId);
      return productModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get products by promo: $e');
    }
  }

  @override
  Future<List<Product>> getActiveProducts() async {
    try {
      final productModels = await _remoteDataSource.getActiveProducts();
      return productModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get active products: $e');
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final productModel = await _remoteDataSource.getProductById(id);
      return productModel?.toEntity();
    } catch (e) {
      throw Exception('Failed to get product by id: $e');
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final productModels = await _remoteDataSource.searchProducts(query);
      return productModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // @override
  // Future<void> debugFixProductStatus() async {
  //   await _remoteDataSource.debugFixProductStatus();
  // }
}
