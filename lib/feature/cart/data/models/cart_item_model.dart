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
      product: ProductModel.fromMap(
        data['product'] ?? {},
        data['productId'] ?? '',
      ).toEntity(),
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
}
