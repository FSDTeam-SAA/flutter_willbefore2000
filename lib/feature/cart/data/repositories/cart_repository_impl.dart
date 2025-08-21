import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../sources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CartItem>> getCartItems() async {
    return await remoteDataSource.getCartItems();
  }

  @override
  Stream<List<CartItem>> getCartItemsStream() {
    return remoteDataSource.getCartItemsStream();
  }

  @override
  Future<void> addCartItem(CartItem item) async {
    await remoteDataSource.addCartItem(item);
  }

  @override
  Future<void> updateCartItem(String itemId, int quantity) async {
    await remoteDataSource.updateCartItem(itemId, quantity);
  }

  @override
  Future<void> removeCartItem(String itemId) async {
    await remoteDataSource.removeCartItem(itemId);
  }

  @override
  Future<void> clearCart() async {
    await remoteDataSource.clearCart();
  }

  @override
  Future<CartItem?> findExistingItem(
    String productId,
    String? size,
    String? color,
  ) async {
    return await remoteDataSource.findExistingItem(productId, size, color);
  }

  @override
  Future<void> updateCartItemVariant(CartItem item) async {
    await remoteDataSource.updateCartItemVariant(item);
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final remoteDataSource = CartRemoteDataSource(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
  return CartRepositoryImpl(remoteDataSource);
});
