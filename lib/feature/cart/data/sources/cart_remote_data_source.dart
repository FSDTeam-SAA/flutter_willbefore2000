import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutx_core/flutx_core.dart';

import '../models/cart_item_model.dart';
import '../../domain/entities/cart_item.dart';

class CartRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CartRemoteDataSource(this._firestore, this._auth);

  // static const String _collection = 'carts';

  String? get _userId => _auth.currentUser?.uid;

  Future<List<CartItem>> getCartItems() async {
    try {
      if (_userId == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cartItems')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      DPrint.log("Error getting cart items: $e");
      throw Exception("Failed to get cart items: $e");
    }
  }

  Stream<List<CartItem>> getCartItemsStream() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('cartItems')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CartItemModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addCartItem(CartItem item) async {
    try {
      if (_userId == null) throw Exception("User not authenticated");

      final cartItemModel = CartItemModel.fromCartItem(item);
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cartItems')
          .doc(item.id)
          .set(cartItemModel.toFirestore());
    } catch (e) {
      DPrint.log("Error adding cart item: $e");
      throw Exception("Failed to add cart item: $e");
    }
  }

  Future<void> updateCartItem(String itemId, int quantity) async {
    try {
      if (_userId == null) throw Exception("User not authenticated");

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cartItems')
          .doc(itemId)
          .update({
            'quantity': quantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      DPrint.log("Error updating cart item: $e");
      throw Exception("Failed to update cart item: $e");
    }
  }

  Future<void> updateCartItemVariant(CartItem item) async {
    try {
      if (_userId == null) throw Exception("User not authenticated");

      final cartItemModel = CartItemModel.fromCartItem(item);
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cartItems')
          .doc(item.id)
          .update({
            ...cartItemModel.toFirestore(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      DPrint.log("Error updating cart item variant: $e");
      throw Exception("Failed to update cart item variant: $e");
    }
  }

  Future<void> removeCartItem(String itemId) async {
    try {
      if (_userId == null) throw Exception("User not authenticated");

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cartItems')
          .doc(itemId)
          .delete();
    } catch (e) {
      DPrint.log("Error removing cart item: $e");
      throw Exception("Failed to remove cart item: $e");
    }
  }

  Future<void> clearCart() async {
    try {
      if (_userId == null) throw Exception("User not authenticated");

      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cartItems')
          .get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      DPrint.log("Error clearing cart: $e");
      throw Exception("Failed to clear cart: $e");
    }
  }

  Future<CartItem?> findExistingItem(
    String productId,
    String? size,
    String? color,
  ) async {
    try {
      if (_userId == null) return null;

      Query query = _firestore
          .collection('users')
          .doc(_userId)
          .collection('cartItems')
          .where('productId', isEqualTo: productId);

      if (size != null) {
        query = query.where('selectedSize', isEqualTo: size);
      }
      if (color != null) {
        query = query.where('selectedColor', isEqualTo: color);
      }

      final querySnapshot = await query.limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return CartItemModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }

      return null;
    } catch (e) {
      DPrint.log("Error finding existing cart item: $e");
      return null;
    }
  }
}
