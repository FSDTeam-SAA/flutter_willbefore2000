import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smilestreats/core/styles/decorations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/hero_tag_manager.dart';
import '../../domain/entrity/product.dart';
import 'product_card.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final bool isHorizontal;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
    required this.isLoading,
    this.onSeeAll,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSansKr(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textAppBlack,
                ),
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: Text(
                    'See All',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryLaurel,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            _buildLoadingProducts()
          else if (isHorizontal)
            _buildHorizontalProducts(context)
          else
            _buildVerticalProducts(),
        ],
      ),
    );
  }

  Widget _buildHorizontalProducts(BuildContext context) {
    // Take up to 4 products to display in the grid
    final displayProducts = products.take(4).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Adjust crossAxisCount and childAspectRatio based on screen size
    final crossAxisCount = isTablet
        ? 3
        : 2; // 3 columns for tablets, 2 for phones
    final childAspectRatio = isTablet
        ? 0.75
        : 0.70; // Slightly taller cards on phones
    final spacing = isTablet ? 16.0 : 12.0; // Larger spacing on tablets

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: displayProducts.length,
      itemBuilder: (context, index) {
        final product = displayProducts[index];
        String heroTag;
        switch (title.toLowerCase()) {
          case 'most popular':
            heroTag = HeroTagManager.forHomePopular(product.id, index);
            break;
          case 'new arrivals':
            heroTag = HeroTagManager.forHomeNewArrivals(product.id, index);
            break;
          case 'for you':
            heroTag = HeroTagManager.forHomeForYou(product.id, index);
            break;
          default:
            heroTag = HeroTagManager.forProductList(product.id, index);
        }

        return ProductCard(
          product: product,
          isHorizontal: true,
          heroTag: heroTag,
        );
      },
    );
  }

  Widget _buildVerticalProducts() {
    final items = products.take(2).toList();

    return Container(
      decoration: AppDecorations.cardDecoration,
      padding: EdgeInsets.all(10),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;

          String heroTag;
          switch (title.toLowerCase()) {
            case 'most popular':
              heroTag = HeroTagManager.forHomePopular(product.id, index);
              break;
            case 'new arrivals':
              heroTag = HeroTagManager.forHomeNewArrivals(product.id, index);
              break;
            case 'for you':
              heroTag = HeroTagManager.forHomeForYou(product.id, index);
              break;
            default:
              heroTag = HeroTagManager.forProductList(product.id, index);
          }

          return Container(
            margin: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
            child: ProductCard(
              product: product,
              isHorizontal: false,
              heroTag: heroTag, // Pass context-specific hero tag
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingProducts() {
    return isHorizontal
        ? SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildLoadingCard(),
                );
              },
            ),
          )
        : Column(
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildLoadingCard(),
              ),
            ),
          );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
