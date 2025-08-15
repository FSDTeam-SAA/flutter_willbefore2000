import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smilestreats/core/styles/decorations.dart';

import '../../../../core/constants/app_colors.dart';
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
            _buildHorizontalProducts()
          else
            _buildVerticalProducts(),
        ],
      ),
    );
  }

  Widget _buildHorizontalProducts() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: ProductCard(product: product, isHorizontal: true),
          );
        },
      ),
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

          return Container(
            margin: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
            child: ProductCard(
              product: product,
              isHorizontal: false,
              heroTag: "product-card-${product.id}",
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
