import '../entrity/product.dart';

abstract class ProductsRepository {
  Future<List<Product>> getAllProducts();
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> getProductsByPromo(String promoId);
  Future<List<Product>> getActiveProducts();
  Future<Product?> getProductById(String id);
  Future<List<Product>> searchProducts(String query);
}
