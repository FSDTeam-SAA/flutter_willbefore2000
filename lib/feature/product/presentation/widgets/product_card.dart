import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added Riverpod import
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smilestreats/core/common/widgets/app_cached_image.dart';
import 'package:smilestreats/core/styles/decorations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';
import '../../../../core/utils/hero_tag_manager.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entrity/product.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final bool isHorizontal;
  final String? heroTag;

  const ProductCard({
    super.key,
    required this.product,
    this.isHorizontal = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef parameter
    final uniqueHeroTag =
        heroTag ??
        HeroTagManager.generateProductHeroTag(
          productId: product.id,
          context: 'fallback',
        );

    return GestureDetector(
      onTap: () => context.push(
        '${RoutePaths.product}/${product.id}',
        extra: uniqueHeroTag, // Pass the hero tag as extra data
      ),
      child: Container(
        child: isHorizontal
            ? _buildHorizontalCard(context, ref, uniqueHeroTag) // Added context and ref parameters
            : _buildVerticalCard(context, ref, uniqueHeroTag), // Added context and ref parameters
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context, WidgetRef ref, String uniqueHeroTag) { // Added context and ref parameters
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        final cardWidth = constraints.maxWidth;

        return Container(
          width: double.infinity,
          decoration: AppDecorations.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Image
              Hero(
                tag: uniqueHeroTag,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    height: isSmallScreen ? 175 : 200, // Responsive height
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: product.imageUrls.isNotEmpty
                          ? AppCachedImage(
                              imageUrl: product.imageUrls.first,
                              fit: BoxFit.cover,
                            )
                          : Placeholder(),
                    ),
                  ),
                ),
              ),
              // Product Details - Fixed overflow issues
              Padding(
                padding: EdgeInsets.all(
                  isSmallScreen ? 6.0 : 8.0,
                ), // Responsive padding
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: cardWidth - (isSmallScreen ? 60 : 72),
                            child: Text(
                              product.title,
                              style: GoogleFonts.notoSansKr(
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textAppBlack,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 2 : 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: isSmallScreen ? 12 : 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '4.8',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textAppBlack,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(98)',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondaryHintColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: isSmallScreen ? 4 : 8,
                          ), // Responsive spacing
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    product.formattedPrice,
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: isSmallScreen ? 12 : 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryLaurel,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (product.isOnSale &&
                                    product.formattedDiscountPrice != null) ...[
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      product.formattedDiscountPrice!,
                                      style: GoogleFonts.notoSansKr(
                                        fontSize: isSmallScreen ? 10 : 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textSecondaryHintColor,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Add product to cart with default quantity of 1
                        ref.read(cartProvider.notifier).addToCart(
                          product,
                          1, // Default quantity
                          null, // No size selected
                          null, // No color selected
                        );
                        
                        // Show snackbar confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.title} added to cart',
                              style: GoogleFonts.notoSansKr(),
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.primaryLaurel,
                          ),
                        );
                      },
                      child: Container(
                        width: isSmallScreen ? 28 : 32,
                        height: isSmallScreen ? 28 : 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primaryLaurel.withOpacity(0.1), // Added background color
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.primaryLaurel, // Changed color to primary
                          size: isSmallScreen ? 16 : 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerticalCard(BuildContext context, WidgetRef ref, String uniqueHeroTag) { // Added context and ref parameters
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  children: [
                    Hero(
                      tag: uniqueHeroTag,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 80,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderColor),
                            color: Colors.grey[100],
                          ),
                          child: AppCachedImage(
                            imageUrl: product.imageUrls.first,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    if (product.isOnSale)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLaurel,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'New',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Gap.w20,
              // Product Details
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textAppBlack,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(98)',
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondaryHintColor,
                            ),
                          ),
                        ],
                      ),
                      Gap.h8,

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                product.formattedPrice,
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryLaurel,
                                ),
                              ),

                              if (product.isOnSale) ...[
                                Gap.w4,
                                Text(
                                  product.formattedDiscountPrice ?? '',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textSecondaryHintColor,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              // Add product to cart with default quantity of 1
              ref.read(cartProvider.notifier).addToCart(
                product,
                1, // Default quantity
                null, // No size selected
                null, // No color selected
              );
              
              // Show snackbar confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${product.title} added to cart',
                    style: GoogleFonts.notoSansKr(),
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.primaryLaurel,
                ),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primaryLaurel.withOpacity(0.1), // Added background color
              ),
              child: Icon(
                Icons.add, 
                color: AppColors.primaryLaurel, // Changed color to primary
                size: 18
              ),
            ),
          ),
        ],
      ),
    );
  }
}
