import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Stream<List<CartItem>> getCartItemsStream();
  Future<void> addCartItem(CartItem item);
  Future<void> updateCartItem(String itemId, int quantity);
  Future<void> removeCartItem(String itemId);
  Future<void> clearCart();
  Future<CartItem?> findExistingItem(
    String productId,
    String? size,
    String? color,
  );
  Future<void> updateCartItemVariant(CartItem item);
}
