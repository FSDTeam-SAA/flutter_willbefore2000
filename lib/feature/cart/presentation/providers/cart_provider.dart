import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../product/domain/entrity/product.dart';
import '../../domain/entities/cart_item.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/repositories/cart_repository.dart';

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? errorMessage;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get tax {
    return 0.0; // No tax for now
  }

  double get total {
    return subtotal + tax;
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repository;

  CartNotifier(this._repository) : super(const CartState()) {
    _initializeCart();
    _listenToCartChanges();
  }

  void _initializeCart() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await loadCartItems();
    }
  }

  void _listenToCartChanges() {
    _repository.getCartItemsStream().listen(
      (items) {
        state = state.copyWith(items: items, isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> loadCartItems() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final items = await _repository.getCartItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addToCart(
    Product product,
    int quantity,
    String? size,
    String? color,
  ) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final existingItem = await _repository.findExistingItem(
        product.id,
        size,
        color,
      );

      if (existingItem != null) {
        await _repository.updateCartItem(
          existingItem.id,
          existingItem.quantity + quantity,
        );
      } else {
        final newItem = CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: product,
          quantity: quantity,
          selectedSize: size,
          selectedColor: color,
        );
        await _repository.addCartItem(newItem);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<CartItem> buyNow(
    Product product,
    int quantity,
    String? size,
    String? color,
  ) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Create a temporary CartItem for the "Buy Now" purchase
      final buyNowItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        selectedSize: size,
        selectedColor: color,
      );

      state = state.copyWith(isLoading: false);
      return buyNowItem; // Return the item for checkout processing
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow; // Rethrow the error for the caller to handle
    }
  }

  CartItem? getExistingCartItem(String productId, String? size, String? color) {
    try {
      return state.items.firstWhere(
        (item) =>
            item.product.id == productId &&
            item.selectedSize == size &&
            item.selectedColor == color,
      );
    } catch (e) {
      return null;
    }
  }

  bool hasProductInCart(String productId) {
    return state.items.any((item) => item.product.id == productId);
  }

  List<CartItem> getProductVariantsInCart(String productId) {
    return state.items.where((item) => item.product.id == productId).toList();
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(itemId);
        return;
      }

      await _repository.updateCartItem(itemId, newQuantity);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      await _repository.removeCartItem(itemId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> clearCart() async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.clearCart();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateCartItemVariant(
    String productId,
    String? oldSize,
    String? oldColor,
    String? newSize,
    String? newColor,
    int newQuantity,
  ) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      // Find the existing item
      final existingItem = state.items.firstWhereOrNull(
        (item) =>
            item.product.id == productId &&
            item.selectedSize == oldSize &&
            item.selectedColor == oldColor,
      );

      if (existingItem != null) {
        // Check if new variant already exists
        final newVariantExists = state.items.any(
          (item) =>
              item.product.id == productId &&
              item.selectedSize == newSize &&
              item.selectedColor == newColor &&
              item.id != existingItem.id,
        );

        if (newVariantExists) {
          // Merge with existing variant
          final targetItem = state.items.firstWhere(
            (item) =>
                item.product.id == productId &&
                item.selectedSize == newSize &&
                item.selectedColor == newColor,
          );

          await _repository.updateCartItem(
            targetItem.id,
            targetItem.quantity + newQuantity,
          );
          await _repository.removeCartItem(existingItem.id);
        } else {
          // Update existing item with new variants
          final updatedItem = CartItem(
            id: existingItem.id,
            product: existingItem.product,
            quantity: newQuantity,
            selectedSize: newSize,
            selectedColor: newColor,
          );
          await _repository.updateCartItemVariant(updatedItem);
        }
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return CartNotifier(repository);
});
