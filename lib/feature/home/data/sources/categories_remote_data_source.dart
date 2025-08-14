import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutx_core/flutx_core.dart';

import '../../domain/models/category_model.dart';

class CategoriesRemoteDataSource {
  final FirebaseFirestore _firestore;

  CategoriesRemoteDataSource(this._firestore);

  static const String _collection = 'categories';

  Future<List<CategoryModel>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      DPrint.log("Error getting categories: $e");
      throw Exception("Failed to get categories: $e");
    }
  }

  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}
