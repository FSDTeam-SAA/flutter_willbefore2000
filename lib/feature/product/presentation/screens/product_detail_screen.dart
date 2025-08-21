import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smilestreats/core/common/widgets/app_cached_image.dart';
import 'package:smilestreats/core/utils/extensions/button_extensions.dart';

import '../../../../core/common/widgets/html_content_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/hero_tag_manager.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/products_details_provider.dart';
import '../providers/products_providers.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final String? heroTag;

  const ProductDetailScreen({super.key, required this.productId, this.heroTag});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late PageController _pageController;
  bool _isPageViewChanging = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final productDetailState = ref.watch(productDetailProvider);

    ref.listen(
      productDetailProvider.select((state) => state.currentImageIndex),
      (previous, next) {
        if (!_isPageViewChanging &&
            _pageController.hasClients &&
            previous != next) {
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
    );

    // Initialize products if needed
    ref.listen(productsProvider, (previous, next) {
      if (previous?.products.isEmpty == true && next.products.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(productsProvider.notifier).fetchProducts();
        });
      }
    });

    if (productsState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final product = productsState.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => throw Exception('Product not found'),
    );

    final effectiveHeroTag =
        widget.heroTag ??
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
            actions: [
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(
              //     Icons.favorite_border,
              //     color: AppColors.textAppBlack,
              //   ),
              // ),
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.share, color: AppColors.textAppBlack),
              // ),
            ],
          ),

          // Product Images
          SliverToBoxAdapter(
            child: Hero(
              tag: effectiveHeroTag,
              child: _buildImageSection(
                context,
                ref,
                product,
                productDetailState,
              ),
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
                    style: GoogleFonts.notoSansKr(
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
                        style: GoogleFonts.notoSansKr(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLaurel,
                        ),
                      ),
                      if (product.isOnSale) ...[
                        const SizedBox(width: 12),
                        Text(
                          product.formattedDiscountPrice ?? '',
                          style: GoogleFonts.notoSansKr(
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
                  Row(
                    children: [
                      const Icon(Icons.star, size: 20, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textAppBlack,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(98 reviews)',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondaryHintColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: GoogleFonts.notoSansKr(
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
                    _buildSizeSelection(
                      context,
                      ref,
                      product,
                      productDetailState,
                    ),

                  const SizedBox(height: 24),

                  // Color Selection
                  if (product.colors.isNotEmpty)
                    _buildColorSelection(
                      context,
                      ref,
                      product,
                      productDetailState,
                    ),

                  const SizedBox(height: 24),

                  // Quantity Selection
                  _buildQuantitySelection(
                    context,
                    ref,
                    product,
                    productDetailState,
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(
                    context,
                    ref,
                    product,
                    productDetailState,
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

  Widget _buildImageSection(
    BuildContext context,
    WidgetRef ref,
    dynamic product,
    ProductDetailState state,
  ) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          // Main Image
          Expanded(
            child: PageView.builder(
              controller: _pageController, // Added PageController
              itemCount: product.imageUrls.isNotEmpty
                  ? product.imageUrls.length
                  : 1,
              onPageChanged: (index) {
                _isPageViewChanging = true;
                ref
                    .read(productDetailProvider.notifier)
                    .updateImageIndex(index);
                Future.delayed(const Duration(milliseconds: 100), () {
                  _isPageViewChanging = false;
                });
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
                    child: AppCachedImage(imageUrl: product.imageUrls[index]),
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
                        child: AppCachedImage(
                          imageUrl: product.imageUrls.isNotEmpty
                              ? product.imageUrls[index]
                              : '/placeholder.svg?height=80&width=80',
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
              style: GoogleFonts.notoSansKr(
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
              style: GoogleFonts.notoSansKr(
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

  Widget _buildSizeSelection(
    BuildContext context,
    WidgetRef ref,
    dynamic product,
    ProductDetailState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: GoogleFonts.notoSansKr(
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
                    style: GoogleFonts.notoSansKr(
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
    BuildContext context,
    WidgetRef ref,
    dynamic product,
    ProductDetailState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: GoogleFonts.notoSansKr(
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
            final index = entry.key;
            final colorName = entry.value;
            final isSelected = state.selectedColor == colorName;

            // Get color from colorCodes if available
            Color color = Colors.grey;
            if (index < product.colorCodes.length) {
              try {
                final colorCode = product.colorCodes[index];
                final cleanColorCode = colorCode.replaceAll('#', '');
                if (cleanColorCode.length == 6) {
                  color = Color(int.parse('FF$cleanColorCode', radix: 16));
                }
              } catch (e) {
                color = Colors.grey;
              }
            }

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
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  colorName,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getTextColorForBackground(color),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildQuantitySelection(
    BuildContext context,
    WidgetRef ref,
    dynamic product,
    ProductDetailState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: GoogleFonts.notoSansKr(
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
              style: GoogleFonts.notoSansKr(
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
              style: GoogleFonts.notoSansKr(
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
    dynamic product,
    ProductDetailState state,
  ) {
    return Row(
      children: [
        Expanded(
          child: context.secondaryButton(
            isLoading: ref.watch(cartProvider).isLoading,
            onPressed: () {
              ref
                  .read(cartProvider.notifier)
                  .addToCart(
                    product,
                    state.quantity,
                    state.selectedSize,
                    state.selectedColor,
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added to cart!',
                    style: GoogleFonts.notoSansKr(),
                  ),
                  backgroundColor: AppColors.primaryLaurel,
                ),
              );
            },
            text: "Added to cart",
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: context.primaryButton(onPressed: () {}, text: "Buy Now"),
        ),
      ],
    );
  }
}
