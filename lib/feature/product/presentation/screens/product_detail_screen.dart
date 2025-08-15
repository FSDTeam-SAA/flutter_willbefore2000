import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/products_providers.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    
    if (productsState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final product = productsState.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => throw Exception('Product not found'),
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
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textAppBlack,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.favorite_border,
                  color: AppColors.textAppBlack,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                  color: AppColors.textAppBlack,
                ),
              ),
            ],
          ),

          // Product Images
          SliverToBoxAdapter(
            child: Hero(
              tag: 'product-${product.id}',
              child: _buildImageSection(product),
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
                      const Icon(
                        Icons.star,
                        size: 20,
                        color: Colors.amber,
                      ),
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
                  Text(
                    product.description.isNotEmpty 
                        ? product.description 
                        : 'A beautiful floral summer dress perfect for warm weather. Made with lightweight, breathable fabric for maximum comfort.',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondaryColor,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Features
                  _buildFeatures(),

                  const SizedBox(height: 24),

                  // Size Selection
                  if (product.sizes.isNotEmpty) _buildSizeSelection(product),

                  const SizedBox(height: 24),

                  // Color Selection
                  if (product.colors.isNotEmpty) _buildColorSelection(product),

                  const SizedBox(height: 24),

                  // Quantity Selection
                  _buildQuantitySelection(product),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(product),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(product) {
    return Container(
      height: 400,
      child: Column(
        children: [
          // Main Image
          Expanded(
            child: PageView.builder(
              itemCount: product.imageUrls.isNotEmpty ? product.imageUrls.length : 1,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
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
                    child: Image.network(
                      product.imageUrls.isNotEmpty
                          ? product.imageUrls[index]
                          : '/placeholder.svg?height=400&width=400',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.grey,
                          ),
                        );
                      },
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
                  final isSelected = index == _currentImageIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentImageIndex = index;
                      });
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
            const Icon(
              Icons.refresh,
              size: 20,
              color: AppColors.primaryLaurel,
            ),
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

  Widget _buildSizeSelection(product) {
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
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
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

  Widget _buildColorSelection(product) {
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
            final isSelected = _selectedColor == colorName;
            
            // Get color from colorCodes if available
            Color color = Colors.grey;
            if (index < product.colorCodes.length) {
              try {
                final colorCode = product.colorCodes[index];
                // Remove # if present and ensure it's a valid hex color
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
                setState(() {
                  _selectedColor = colorName;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    // Calculate luminance to determine if text should be black or white
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildQuantitySelection(product) {
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
                if (_quantity > 1) {
                  setState(() {
                    _quantity--;
                  });
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.remove,
                  color: AppColors.textAppBlack,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              _quantity.toString(),
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textAppBlack,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _quantity++;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLaurel,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),
            Text(
              'Total: \$${(product.effectivePrice * _quantity).toStringAsFixed(2)}',
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

  Widget _buildActionButtons(product) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Add to cart logic
              ref.read(cartProvider.notifier).addToCart(
                product,
                _quantity,
                _selectedSize,
                _selectedColor,
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
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.primaryLaurel),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Add to Cart',
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLaurel,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Buy now logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLaurel,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Buy Now',
              style: GoogleFonts.notoSansKr(
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
