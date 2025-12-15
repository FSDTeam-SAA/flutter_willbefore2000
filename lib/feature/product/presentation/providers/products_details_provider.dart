import 'package:flutter_riverpod/legacy.dart';

class ProductDetailState {
  final int currentImageIndex;
  final String? selectedSize;
  final String? selectedColor;
  final int quantity;

  const ProductDetailState({
    this.currentImageIndex = 0,
    this.selectedSize,
    this.selectedColor,
    this.quantity = 1,
  });

  ProductDetailState copyWith({
    int? currentImageIndex,
    String? selectedSize,
    String? selectedColor,
    int? quantity,
  }) {
    return ProductDetailState(
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      quantity: quantity ?? this.quantity,
    );
  }
}

class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier() : super(const ProductDetailState());

  void updateImageIndex(int index) {
    state = state.copyWith(currentImageIndex: index);
  }

  void selectSize(String size) {
    state = state.copyWith(selectedSize: size);
  }

  void selectColor(String color) {
    state = state.copyWith(selectedColor: color);
  }

  void incrementQuantity() {
    state = state.copyWith(quantity: state.quantity + 1);
  }

  void decrementQuantity() {
    if (state.quantity > 1) {
      state = state.copyWith(quantity: state.quantity - 1);
    }
  }

  void resetState() {
    state = const ProductDetailState();
  }
}

// Provider for product detail state
final productDetailProvider = StateNotifierProvider.autoDispose<ProductDetailNotifier, ProductDetailState>(
  (ref) => ProductDetailNotifier(),
);
