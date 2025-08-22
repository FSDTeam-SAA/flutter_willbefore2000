import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../product/domain/models/product_model.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.product,
    required super.quantity,
    super.selectedSize,
    super.selectedColor,
  });

  factory CartItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CartItemModel(
      id: id,
      product: ProductModel.fromMap(data['product'] ?? {}, data['productId'] ?? '').toEntity(),
      quantity: data['quantity'] ?? 1,
      selectedSize: data['selectedSize'],
      selectedColor: data['selectedColor'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': product.id,
      'product': ProductModel.fromEntity(product).toFirestore(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory CartItemModel.fromCartItem(CartItem item) {
    return CartItemModel(
      id: item.id,
      product: item.product,
      quantity: item.quantity,
      selectedSize: item.selectedSize,
      selectedColor: item.selectedColor,
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    return CartItemModel(
      id: data['id'] ?? '',
      product: ProductModel.fromMap(data['product'] ?? {}, data['productId'] ?? '').toEntity(),
      quantity: data['quantity'] ?? 1,
      selectedSize: data['selectedSize'],
      selectedColor: data['selectedColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': product.id,
      'product': ProductModel.fromEntity(product).toMap(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }

  double get itemSubtotal {
    return product.effectivePrice * quantity;
  }

  double get itemSavings {
    if (product.isOnSale) {
      return product.savingsAmount * quantity;
    }
    return 0.0;
  }

  String get formattedItemSubtotal {
    return '\$${itemSubtotal.toStringAsFixed(2)}';
  }

  String get formattedItemSavings {
    return '\$${itemSavings.toStringAsFixed(2)}';
  }

  bool get hasValidSelection {
    final needsSize = product.sizes.isNotEmpty;
    final needsColor = product.colors.isNotEmpty;
    
    if (needsSize && (selectedSize == null || selectedSize!.isEmpty)) {
      return false;
    }
    
    if (needsColor && (selectedColor == null || selectedColor!.isEmpty)) {
      return false;
    }
    
    return true;
  }

  String? get selectionError {
    if (product.sizes.isNotEmpty && (selectedSize == null || selectedSize!.isEmpty)) {
      return 'Please select a size';
    }
    
    if (product.colors.isNotEmpty && (selectedColor == null || selectedColor!.isEmpty)) {
      return 'Please select a color';
    }
    
    return null;
  }
}
