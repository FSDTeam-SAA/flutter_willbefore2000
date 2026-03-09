// import 'package:flutter/material.dart';
//
// import 'package:smilestreatsapp/core/styles/decorations.dart';

// import '../../../../core/constants/app_colors.dart';
// import '../../../product/domain/entrity/product.dart';
// import '../../../product/presentation/widgets/product_card.dart';

// class ProductSection extends StatelessWidget {
//   final String title;
//   final List<Product> products;
//   final bool isLoading;
//   final VoidCallback? onSeeAll;
//   final bool isHorizontal;

//   const ProductSection({
//     super.key,
//     required this.title,
//     required this.products,
//     required this.isLoading,
//     this.onSeeAll,
//     this.isHorizontal = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isTablet = screenWidth > 600;

//     return Container(
//       margin: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
//             child: Row(
//               children: [
//                 Flexible(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: isTablet ? 24 : 20,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.textAppBlack,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 if (onSeeAll != null)
//                   TextButton(
//                     onPressed: onSeeAll,
//                     child: Text(
//                       'See All',
//                       style: TextStyle(
//                         fontSize: isTablet ? 16 : 14,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.primaryLaurel,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           SizedBox(height: isTablet ? 16 : 12),
//           if (isLoading)
//             _buildLoadingState(isTablet, context)
//           else if (products.isEmpty)
//             _buildEmptyState(isTablet)
//           else
//             _buildProductList(isTablet, context),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingState(bool isTablet, BuildContext context) {
//     final cardWidth = isTablet ? 200.0 : 160.0;
//     final cardHeight = isTablet ? 280.0 : 240.0;

//     if (isHorizontal) {
//       return SizedBox(
//         height: cardHeight,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
//           itemCount: 4,
//           itemBuilder: (context, index) {
//             return Container(
//               width: cardWidth,
//               margin: EdgeInsets.only(right: isTablet ? 16 : 12),
//               child: _buildShimmerCard(isTablet),
//             );
//           },
//         ),
//       );
//     } else {
//       return Padding(
//         padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
//         child: Wrap(
//           spacing: isTablet ? 16 : 12,
//           runSpacing: isTablet ? 16 : 12,
//           children: List.generate(
//             4,
//             (index) => SizedBox(
//               width:
//                   (MediaQuery.of(context).size.width - (isTablet ? 64 : 44)) /
//                   2,
//               child: _buildShimmerCard(isTablet),
//             ),
//           ),
//         ),
//       );
//     }
//   }

//   Widget _buildShimmerCard(bool isTablet) {
//     return Container(
//       height: isTablet ? 280 : 240,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             height: isTablet ? 180 : 150,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(isTablet ? 16 : 12),
//               ),
//             ),
//           ),
//           Container(
//             height: isTablet ? 100 : 90,
//             padding: EdgeInsets.all(isTablet ? 16 : 12),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: isTablet ? 16 : 14,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//                 SizedBox(height: isTablet ? 12 : 8),
//                 Container(
//                   height: isTablet ? 14 : 12,
//                   width: isTablet ? 80 : 60,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState(bool isTablet) {
//     return Container(
//       height: isTablet ? 200 : 160,
//       margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.inventory_2_outlined,
//               size: isTablet ? 48 : 40,
//               color: Colors.grey[400],
//             ),
//             SizedBox(height: isTablet ? 12 : 8),
//             Text(
//               'No products available',
//               style: TextStyle(
//                 fontSize: isTablet ? 16 : 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductList(bool isTablet, BuildContext context) {
//     final cardWidth = isTablet ? 200.0 : 160.0;
//     final cardHeight = isTablet ? 280.0 : 240.0;

//     if (isHorizontal) {
//       return Container(
//         height: cardHeight,
//         color: AppColors.bgColor,
//         decoration: AppDecorations.cardDecoration,
//         child: ListView.builder(
//           padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
//           itemCount: 2,
//           itemBuilder: (context, index) {
//             final product = products[index];
//             return Container(
//               width: cardWidth,
//               margin: EdgeInsets.only(right: isTablet ? 16 : 12),
//               child: ProductCard(
//                 product: product,
//                 heroTag: '${title.toLowerCase().replaceAll(' ', '-')}-$index',
//               ),
//             );
//           },
//         ),
//       );
//     } else {
//       return Padding(
//         padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
//         child: Wrap(
//           spacing: isTablet ? 16 : 12,
//           runSpacing: isTablet ? 16 : 12,
//           children: products.map((product) {
//             final index = products.indexOf(product);
//             return SizedBox(
//               width:
//                   (MediaQuery.of(context).size.width - (isTablet ? 64 : 44)) /
//                   2,
//               child: ProductCard(
//                 product: product,
//                 heroTag: '${title.toLowerCase().replaceAll(' ', '-')}-$index',
//               ),
//             );
//           }).toList(),
//         ),
//       );
//     }
//   }
// }
