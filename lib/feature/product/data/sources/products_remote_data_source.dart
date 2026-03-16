import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutx_core/flutx_core.dart';
import '../../domain/models/product_migration_helper.dart';
import '../../domain/models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<List<ProductModel>> getProductsByCategory(String categoryId);
  Future<List<ProductModel>> getProductsByPromo(String promoId);
  Future<List<ProductModel>> getActiveProducts();
  Future<ProductModel?> getProductById(String id);
  // Future<void> toggleProductStatus(String id, bool isActive);
  Future<List<ProductModel>> searchProducts(String query);
  Future<void> debugFixProductStatus();
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProductsRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('products')
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) => _safeFromFirestore(doc)).toList();
    } 
    catch (e) {
      throw Exception('Failed to get all products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('products')
              .where('categoryId', isEqualTo: categoryId)
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) => _safeFromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        DPrint.error("MISSING INDEX for Category search. Fallback active.");
        final querySnapshot =
            await _firestore
                .collection('products')
                .where('categoryId', isEqualTo: categoryId)
                .where('isActive', isEqualTo: true)
                .get();

        final products =
            querySnapshot.docs.map((doc) => _safeFromFirestore(doc)).toList();
        products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return products;
      }
      rethrow;
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByPromo(String promoId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('promoId', isEqualTo: promoId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _safeFromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get products by promo: $e');
    }
  }

  @override
  Future<List<ProductModel>> getActiveProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => _safeFromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get active products: $e');
    }
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();

      if (doc.exists) {
        return _safeFromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product by id: $e');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      // Note: This is a basic search. For better search functionality,
      // consider using Algolia or similar search service
      final querySnapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .orderBy('title')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .get();

      return querySnapshot.docs.map((doc) => _safeFromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<void> debugFixProductStatus() async {
    try {
      DPrint.log("Starting debugFixProductStatus...");
      final querySnapshot = await _firestore.collection('products').get();

      final batch = _firestore.batch();
      int count = 0;

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isActive': true});
        count++;
      }

      await batch.commit();
      DPrint.log("Successfully updated $count products to isActive: true");
    } catch (e) {
      DPrint.error("Error in debugFixProductStatus: $e");
    }
  }

  // Safe method to handle both old and new data formats
  ProductModel _safeFromFirestore(DocumentSnapshot doc) {
    try {
      return ProductModel.fromFirestore(doc);
    } catch (e) {
      // Fallback to migration helper for legacy data
      print('Using migration helper for product: ${doc.id}');
      final data = doc.data() as Map<String, dynamic>;
      return ProductMigrationHelper.fromLegacyData(data, doc.id);
    }
  }
}
