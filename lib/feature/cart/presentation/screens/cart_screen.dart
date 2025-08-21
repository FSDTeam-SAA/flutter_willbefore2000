import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smilestreats/core/routes/route_endpoint.dart';
import 'package:smilestreats/core/utils/extensions/button_extensions.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return AppScaffold(
      appBar: AppBar(),
      body: cartState.items.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Cart Items
                Expanded(
                  child: ListView.builder(
                    // padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return CartItemWidget(
                        item: item,
                        onQuantityChanged: (newQuantity) {
                          ref
                              .read(cartProvider.notifier)
                              .updateQuantity(item.id, newQuantity);
                        },
                        onRemove: () {
                          ref
                              .read(cartProvider.notifier)
                              .removeFromCart(item.id);
                        },
                      );
                    },
                  ),
                ),

                // Order Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textAppBlack,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                            Text(
                              '\$${cartState.subtotal.toStringAsFixed(2)}',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textAppBlack,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tax',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                            Text(
                              '\$${cartState.tax.toStringAsFixed(2)}',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textAppBlack,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textAppBlack,
                              ),
                            ),
                            Text(
                              '\$${cartState.total.toStringAsFixed(2)}',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textAppBlack,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: context.primaryButton(
                            // isLoading: authState.isLoading,
                            onPressed: () {
                              context.pushNamed(RoutePaths.checkout);
                            },
                            text: "Continue Shopping",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: GoogleFonts.notoSansKr(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondaryHintColor,
            ),
          ),
        ],
      ),
    );
  }
}
