import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double actualPrice;
  final double? discountPrice;
  final int stock;
  final String categoryId;
  final String? promoId;
  final List<String> sizes;
  final List<String> colors;
  final List<String> colorCodes;
  final List<String> imageUrls;
  final Map<String, dynamic>? facilities;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.actualPrice,
    this.discountPrice,
    required this.stock,
    required this.categoryId,
    this.promoId,
    required this.sizes,
    required this.colors,
    required this.colorCodes,
    required this.imageUrls,
    this.facilities,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? actualPrice,
    double? discountPrice,
    int? stock,
    String? categoryId,
    String? promoId,
    List<String>? sizes,
    List<String>? colors,
    List<String>? colorCodes,
    List<String>? imageUrls,
    Map<String, dynamic>? facilities,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      actualPrice: actualPrice ?? this.actualPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      promoId: promoId ?? this.promoId,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      colorCodes: colorCodes ?? this.colorCodes,
      imageUrls: imageUrls ?? this.imageUrls,
      facilities: facilities ?? this.facilities,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate discount percentage
  double get discountPercentage {
    if (discountPrice == null || discountPrice! >= actualPrice) {
      return 0.0;
    }
    return ((actualPrice - discountPrice!) / actualPrice) * 100;
  }

  // Get effective price (discounted or actual)
  double get effectivePrice {
    return discountPrice ?? actualPrice;
  }

  // Check if product is on sale
  bool get isOnSale {
    return discountPrice != null && discountPrice! < actualPrice;
  }

  // Check if product is in stock
  bool get isInStock {
    return stock > 0;
  }

  // Get stock status
  String get stockStatus {
    if (stock <= 0) return 'Out of Stock';
    if (stock <= 5) return 'Low Stock';
    return 'In Stock';
  }

  // Get stock status color
  Color get stockStatusColor {
    if (stock <= 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  // Get formatted price
  String get formattedPrice {
    return '\$${actualPrice.toStringAsFixed(2)}';
  }

  // Get formatted discount price
  String? get formattedDiscountPrice {
    return discountPrice != null ? '\$${discountPrice!.toStringAsFixed(2)}' : null;
  }

  // Get savings amount
  double get savingsAmount {
    if (discountPrice == null || discountPrice! >= actualPrice) {
      return 0.0;
    }
    return actualPrice - discountPrice!;
  }

  // Get formatted savings
  String get formattedSavings {
    return '\$${savingsAmount.toStringAsFixed(2)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product{id: $id, title: $title, actualPrice: $actualPrice, stock: $stock, isActive: $isActive}';
  }
}
