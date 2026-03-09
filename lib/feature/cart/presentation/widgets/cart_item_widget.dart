import 'package:flutter/material.dart';

import 'package:smilestreatsapp/core/common/widgets/app_cached_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppCachedImage(
                imageUrl: item.product.imageUrls.isNotEmpty
                    ? item.product.imageUrls.first
                    : '/placeholder.svg?height=80&width=80',
              ),

              // Image.network(
              //   item.product.imageUrls.isNotEmpty
              //       ? item.product.imageUrls.first
              //       : '/placeholder.svg?height=80&width=80',
              //   fit: BoxFit.cover,
              //   errorBuilder: (context, error, stackTrace) {
              //     return Container(
              //       color: Colors.grey[200],
              //       child: const Icon(
              //         Icons.image,
              //         size: 30,
              //         color: Colors.grey,
              //       ),
              //     );
              //   },
              // ),
            ),
          ),

          const SizedBox(width: 16),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textAppBlack,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.selectedSize != null || item.selectedColor != null)
                  Text(
                    '${item.selectedSize ?? ''} ${item.selectedColor ?? ''}'
                        .trim(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondaryHintColor,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.product.formattedDiscountPrice.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textAppBlack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Quantity Controls
          Column(
            children: [
              Text(
                'Qty: ${item.quantity}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryColor,
                ),
              ),

              const SizedBox(height: 8),
              // Text(
              //   item.quantity.toString(),
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.w600,
              //     color: AppColors.textAppBlack,
              //   ),
              // ),
              // const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onQuantityChanged(item.quantity - 1),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 18,
                        color: AppColors.textAppBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onQuantityChanged(item.quantity + 1),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLaurel,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
