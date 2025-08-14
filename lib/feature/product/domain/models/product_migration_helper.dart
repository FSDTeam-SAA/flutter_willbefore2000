import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_model.dart';

class ProductMigrationHelper {
  static ProductModel fromLegacyData(Map<String, dynamic> data, String id) {
    // Handle both old and new data formats
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
      // Handle missing colorCodes in legacy data
      colorCodes: List<String>.from(data['colorCodes'] ?? _generateDefaultColorCodes(data['colors'])),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      facilities: data['facilities'] as Map<String, dynamic>?,
      // Handle missing isActive in legacy data
      isActive: data['isActive'] ?? true,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else if (dateValue is String) {
      return DateTime.tryParse(dateValue) ?? DateTime.now();
    }
    
    return DateTime.now();
  }

  static List<String> _generateDefaultColorCodes(dynamic colors) {
    if (colors == null) return [];
    
    final colorList = List<String>.from(colors);
    return colorList.map((colorName) => _getColorCodeFromName(colorName)).toList();
  }

  static String _getColorCodeFromName(String colorName) {
    // Map common color names to hex codes
    final colorMap = {
      'red': 'ffff0000',
      'black': 'ff000000',
      'white': 'ffffffff',
      'blue': 'ff0000ff',
      'green': 'ff00ff00',
      'yellow': 'ffffff00',
      'purple': 'ff800080',
      'orange': 'ffffa500',
      'pink': 'ffffc0cb',
      'grey': 'ff808080',
      'gray': 'ff808080',
    };
    
    return colorMap[colorName.toLowerCase()] ?? 'ff808080'; // Default to gray
  }

  // Method to update legacy products in Firestore
  static Future<void> migrateLegacyProducts() async {
    final firestore = FirebaseFirestore.instance;
    final productsCollection = firestore.collection('products');
    
    try {
      final querySnapshot = await productsCollection.get();
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Check if product needs migration
        if (!data.containsKey('colorCodes') || !data.containsKey('isActive')) {
          final migratedProduct = fromLegacyData(data, doc.id);
          
          // Update the document with missing fields
          await doc.reference.update({
            if (!data.containsKey('colorCodes')) 'colorCodes': migratedProduct.colorCodes,
            if (!data.containsKey('isActive')) 'isActive': migratedProduct.isActive,
          });
          
          print('Migrated product: ${migratedProduct.title}');
        }
      }
      
      print('Product migration completed successfully');
    } catch (e) {
      print('Error during product migration: $e');
      rethrow;
    }
  }
}
