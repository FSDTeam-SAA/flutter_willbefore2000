import 'package:cloud_firestore/cloud_firestore.dart';
import '../entrity/product.dart';

class ProductModel {
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

  const ProductModel({
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

  // Create from Firestore DocumentSnapshot
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ProductModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      actualPrice: (data['actualPrice'] ?? 0.0).toDouble(),
      discountPrice: data['discountPrice']?.toDouble(),
      stock: data['stock'] ?? 0,
      categoryId: data['categoryId'] ?? '',
      promoId: data['promoId'],
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      colorCodes: List<String>.from(data['colorCodes'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      facilities: data['facilities'] as Map<String, dynamic>?,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from Map (for compatibility with your existing code)
  factory ProductModel.fromMap(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      actualPrice: (data['actualPrice'] ?? 0.0).toDouble(),
      discountPrice: data['discountPrice']?.toDouble(),
      stock: data['stock'] ?? 0,
      categoryId: data['categoryId'] ?? '',
      promoId: data['promoId'],
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      colorCodes: List<String>.from(data['colorCodes'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      facilities: data['facilities'] as Map<String, dynamic>?,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: data['updatedAt'] is Timestamp 
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'actualPrice': actualPrice,
      'discountPrice': discountPrice,
      'stock': stock,
      'categoryId': categoryId,
      'promoId': promoId,
      'sizes': sizes,
      'colors': colors,
      'colorCodes': colorCodes,
      'imageUrls': imageUrls,
      'facilities': facilities,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // Convert to Map (for compatibility)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'actualPrice': actualPrice,
      'discountPrice': discountPrice,
      'stock': stock,
      'categoryId': categoryId,
      'promoId': promoId,
      'sizes': sizes,
      'colors': colors,
      'colorCodes': colorCodes,
      'imageUrls': imageUrls,
      'facilities': facilities,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Convert to domain entity
  Product toEntity() {
    return Product(
      id: id,
      title: title,
      description: description,
      actualPrice: actualPrice,
      discountPrice: discountPrice,
      stock: stock,
      categoryId: categoryId,
      promoId: promoId,
      sizes: sizes,
      colors: colors,
      colorCodes: colorCodes,
      imageUrls: imageUrls,
      facilities: facilities,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Create from domain entity
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      title: product.title,
      description: product.description,
      actualPrice: product.actualPrice,
      discountPrice: product.discountPrice,
      stock: product.stock,
      categoryId: product.categoryId,
      promoId: product.promoId,
      sizes: product.sizes,
      colors: product.colors,
      colorCodes: product.colorCodes,
      imageUrls: product.imageUrls,
      facilities: product.facilities,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  ProductModel copyWith({
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
    return ProductModel(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductModel{id: $id, title: $title, actualPrice: $actualPrice, stock: $stock, isActive: $isActive}';
  }
}
