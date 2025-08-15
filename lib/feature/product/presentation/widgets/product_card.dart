import 'package:flutter/material.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smilestreats/core/common/widgets/app_cached_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';
import '../../../../core/utils/hero_tag_manager.dart';
import '../../domain/entrity/product.dart';

class ProductCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final uniqueHeroTag = heroTag ?? 
        HeroTagManager.generateProductHeroTag(
          productId: product.id, 
          context: 'fallback'
        );

    return GestureDetector(
      onTap: () => context.push(
        '${RoutePaths.product}/${product.id}',
        extra: uniqueHeroTag, // Pass the hero tag as extra data
      ),
      child: Container(
        child: isHorizontal ? _buildHorizontalCard(uniqueHeroTag) : _buildVerticalCard(uniqueHeroTag),
      ),
    );
  }

  Widget _buildHorizontalCard(String uniqueHeroTag) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Product Image
          Hero(
            tag: uniqueHeroTag,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppCachedImage(
                    imageUrl: product.imageUrls.first,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
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
                const SizedBox(height: 8),
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
                      const SizedBox(width: 8),
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
          ),
          // Add Button
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLaurel,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalCard(String uniqueHeroTag) {
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
                      tag: uniqueHeroTag, // Add Hero widget to vertical card image
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: AppColors.black, size: 18),
          ),
        ],
      ),
    );
  }
}
