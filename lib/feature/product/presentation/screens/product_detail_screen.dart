import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart'; // Added GoRouter import
import 'package:smilestreatsapp/core/common/widgets/app_cached_image.dart';

import '../../../../core/common/widgets/html_content_widget.dart';
import '../../../../core/common/widgets/login_required_dialog.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';
import '../../../../core/utils/hero_tag_manager.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/products_details_provider.dart';
import '../providers/products_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  final String? heroTag; // Added heroTag parameter to receive from navigation

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.heroTag, // Optional heroTag for Hero animation
  });

  String _getCartButtonText(
    WidgetRef ref,
    product,
    String? selectedSize,
    String? selectedColor,
  ) {
    final cartNotifier = ref.read(cartProvider.notifier);

    // Check if exact variant exists in cart
    final exactMatch = cartNotifier.getExistingCartItem(
      product.id,
      selectedSize,
      selectedColor,
    );

    if (exactMatch != null) {
      return 'Update Cart';
    }

    // Check if product exists with different variants
    final hasProduct = cartNotifier.hasProductInCart(product.id);
    if (hasProduct) {
      return 'Add New Variant';
    }

    return 'Add to Cart';
  }

  void _handleCartAction(
    BuildContext context,
    WidgetRef ref,
    product,
    String? selectedSize,
    String? selectedColor,
    int quantity,
  ) async {
    // Check authentication
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      if (context.mounted) {
        LoginRequiredDialog.show(context);
      }
      return;
    }

    // Validate required selections
    if (product.sizes.isNotEmpty && selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a size', style: TextStyle()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (product.colors.isNotEmpty && selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a color', style: TextStyle()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cartNotifier = ref.read(cartProvider.notifier);

    // Check if exact variant exists in cart
    final exactMatch = cartNotifier.getExistingCartItem(
      product.id,
      selectedSize,
      selectedColor,
    );

    String actionMessage;

    if (exactMatch != null) {
      // Update existing item
      await cartNotifier.updateCartItemVariant(
        product.id,
        exactMatch.selectedSize,
        exactMatch.selectedColor,
        selectedSize,
        selectedColor,
        quantity,
      );
      actionMessage = '${product.title} updated in cart!';
    } else {
      // Add new item or variant
      await cartNotifier.addToCart(
        product,
        quantity,
        selectedSize,
        selectedColor,
      );

      final hasOtherVariants = cartNotifier.hasProductInCart(product.id);
      actionMessage = hasOtherVariants
          ? '${product.title} variant added to cart!'
          : '${product.title} added to cart!';
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(actionMessage, style: TextStyle()),
          backgroundColor: AppColors.primaryLaurel,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              context.go('/cart');
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final cartState = ref.watch(cartProvider);
    final productDetailState = ref.watch(productDetailProvider);

    ref.listen(productsProvider, (previous, next) {
      if (previous?.products.isEmpty == true && next.products.isEmpty) {
        ref.read(productsProvider.notifier).fetchProducts();
      }
    });

    if (productsState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If products are empty, try to fetch them
    if (productsState.products.isEmpty) {
      // Trigger a fetch if products are empty
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(productsProvider.notifier).fetchProducts();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Debug: Print product lookup info
    print('ProductDetailScreen - Looking for product ID: $productId');
    print(
      'ProductDetailScreen - Available products: ${productsState.products.map((p) => p.id).toList()}',
    );

    // Try to find the product
    final productIndex = productsState.products.indexWhere(
      (p) => p.id == productId,
    );

    // If product is not found, show an error screen
    if (productIndex == -1) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Product Not Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textAppBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The product you are looking for does not exist.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLaurel,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  'Go to Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final product = productsState.products[productIndex];

    final effectiveHeroTag =
        heroTag ??
        HeroTagManager.generateProductHeroTag(
          productId: product.id,
          context: 'detail-fallback',
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: true,
            // actions: [
            //   IconButton(
            //     onPressed: () {},
            //     icon: const Icon(
            //       Icons.favorite_border,
            //       color: AppColors.textAppBlack,
            //     ),
            //   ),
            //   IconButton(
            //     onPressed: () {},
            //     icon: const Icon(Icons.share, color: AppColors.textAppBlack),
            //   ),
            // ],
          ),

          // Product Images
          SliverToBoxAdapter(
            child: Hero(
              tag: effectiveHeroTag, // Use the effective hero tag
              child: _buildImageSection(ref, product, productDetailState),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textAppBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLaurel,
                        ),
                      ),
                      if (product.isOnSale) ...[
                        const SizedBox(width: 12),
                        Text(
                          product.formattedDiscountPrice ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondaryHintColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 20, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textAppBlack,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(98 reviews)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondaryHintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stock Status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: product.stockStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.stockStatus,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: product.stockStatusColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textAppBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ProductDescriptionHtml(
                    htmlData: product.description.isNotEmpty
                        ? product.description
                        : '<p>A beautiful floral summer dress perfect for warm weather. Made with lightweight, breathable fabric for maximum comfort.</p>',
                    padding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 24),

                  // Features
                  _buildFeatures(),

                  const SizedBox(height: 24),

                  // Size Selection
                  if (product.sizes.isNotEmpty)
                    _buildSizeSelection(ref, product, productDetailState),

                  const SizedBox(height: 24),

                  // Color Selection
                  if (product.colors.isNotEmpty)
                    _buildColorSelection(ref, product, productDetailState),

                  const SizedBox(height: 24),

                  // Quantity Selection
                  _buildQuantitySelection(ref, product, productDetailState),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(
                    context,
                    ref,
                    product,
                    productDetailState,
                    cartState,
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(WidgetRef ref, product, ProductDetailState state) {
    // Create a PageController with the initial page set to the current image index
    final PageController pageController = PageController(
      initialPage: state.currentImageIndex,
    );

    // Listen to changes in currentImageIndex to update the PageView
    ref.listen(productDetailProvider, (previous, next) {
      if (previous?.currentImageIndex != next.currentImageIndex) {
        pageController.jumpToPage(next.currentImageIndex);
      }
    });

    return SizedBox(
      height: 400,
      child: Column(
        children: [
          // Main Image
          Expanded(
            child: PageView.builder(
              controller: pageController, // Assign the PageController
              itemCount: product.imageUrls.isNotEmpty
                  ? product.imageUrls.length
                  : 1,
              onPageChanged: (index) {
                ref
                    .read(productDetailProvider.notifier)
                    .updateImageIndex(index);
              },
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: product.imageUrls.isNotEmpty
                        ? AppCachedImage(imageUrl: product.imageUrls[index])
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Thumbnail Images
          if (product.imageUrls.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: product.imageUrls.length,
                itemBuilder: (context, index) {
                  final isSelected = index == state.currentImageIndex;
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(productDetailProvider.notifier)
                          .updateImageIndex(index);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryLaurel
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                size: 30,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 20,
              color: AppColors.primaryLaurel,
            ),
            const SizedBox(width: 12),
            Text(
              'Free shipping on orders over \$50',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.refresh, size: 20, color: AppColors.primaryLaurel),
            const SizedBox(width: 12),
            Text(
              '30-day free returns',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSelection(WidgetRef ref, product, ProductDetailState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textAppBlack,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: product.sizes.map<Widget>((size) {
            final isSelected = state.selectedSize == size;
            return GestureDetector(
              onTap: () {
                ref.read(productDetailProvider.notifier).selectSize(size);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLaurel : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryLaurel
                        : Colors.grey[300]!,
                  ),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textAppBlack,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelection(
    WidgetRef ref,
    product,
    ProductDetailState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textAppBlack,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: product.colors.asMap().entries.map<Widget>((entry) {
            // final index = entry.key;
            final colorName = entry.value;
            final isSelected = state.selectedColor == colorName;

            return GestureDetector(
              onTap: () {
                ref.read(productDetailProvider.notifier).selectColor(colorName);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLaurel : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryLaurel
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Text(
                  colorName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textAppBlack, // Consistent text color
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  // Color _getTextColorForBackground(Color backgroundColor) {
  //   final luminance = backgroundColor.computeLuminance();
  //   return luminance > 0.5 ? Colors.black : Colors.white;
  // }

  Widget _buildQuantitySelection(
    WidgetRef ref,
    product,
    ProductDetailState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textAppBlack,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                ref.read(productDetailProvider.notifier).decrementQuantity();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.remove, color: AppColors.textAppBlack),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              state.quantity.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textAppBlack,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                ref.read(productDetailProvider.notifier).incrementQuantity();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLaurel,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
            const Spacer(),
            Text(
              'Total: \$${(product.effectivePrice * state.quantity).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textAppBlack,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    product,
    ProductDetailState state,
    cartState,
  ) {
    final buttonText = _getCartButtonText(
      ref,
      product,
      state.selectedSize,
      state.selectedColor,
    );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: (cartState.isLoading || !product.isInStock)
                ? null
                : () => _handleCartAction(
                      context,
                      ref,
                      product,
                      state.selectedSize,
                      state.selectedColor,
                      state.quantity,
                    ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primaryLaurel),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: cartState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryLaurel,
                      ),
                    ),
                  )
                : Text(
                    !product.isInStock ? 'Out of Stock' : buttonText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: !product.isInStock
                          ? Colors.grey
                          : AppColors.primaryLaurel,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: (cartState.isLoading || !product.isInStock)
                ? null
                : () async {
                    // Check authentication
                    final authState = ref.read(authProvider);
                    if (!authState.isAuthenticated) {
                      if (context.mounted) {
                        LoginRequiredDialog.show(context);
                      }
                      return;
                    }

                    // Validate required selections
                    if (product.sizes.isNotEmpty &&
                        state.selectedSize == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please select a size',
                            style: TextStyle(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (product.colors.isNotEmpty &&
                        state.selectedColor == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please select a color',
                            style: TextStyle(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      final cartItem = await ref
                          .read(cartProvider.notifier)
                          .buyNow(
                            product,
                            state.quantity,
                            state.selectedSize,
                            state.selectedColor,
                          );
                      // Navigate to CheckoutScreen with the single CartItem
                      if (context.mounted) {
                        context.pushNamed(
                          RoutePaths.checkout,
                          extra: {'buyNowItem': cartItem}, // Pass the CartItem
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e', style: TextStyle()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLaurel,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              product.isInStock ? 'Buy Now' : 'Out of Stock',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
