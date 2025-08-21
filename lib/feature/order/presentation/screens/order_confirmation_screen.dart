import 'package:flutter/material.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';
import 'package:smilestreats/core/constants/app_colors.dart';
import 'package:smilestreats/core/routes/route_endpoint.dart';
import 'package:smilestreats/core/utils/extensions/button_extensions.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../domain/entities/order_entities.dart';
import 'package:intl/intl.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Checkout'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: Column(
              children: [
                // Success Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.green, size: 40),
                ),
                const SizedBox(height: 24),

                // Success Message
                const Text(
                  'Thank you for your order!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLaurel,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap.h8,

                const Text(
                  'Your order has been placed successfully.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                Divider(
                  height: 1,
                  color: Colors.grey[300],
                  indent: 20,
                  endIndent: 20,
                ),
                // Order Details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Order Number:', order.orderNumber),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Estimated Delivery:',
                        order.estimatedDelivery != null
                            ? DateFormat(
                                'MMMM dd, yyyy',
                              ).format(order.estimatedDelivery!)
                            : 'TBD',
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: Colors.grey[300],
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 24),

                // Email Confirmation Message
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  // decoration: BoxDecoration(
                  //   color: Colors.blue[50],
                  //   borderRadius: BorderRadius.circular(8),
                  //   border: Border.all(color: Colors.blue[200]!),
                  // ),
                  child: Text(
                    "We've sent a confirmation email to your email address with all the details of your order.",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),

                // Continue Shopping Button
                SizedBox(
                  width: double.infinity,
                  child: context.primaryButton(
                    onPressed: () => context.go(RoutePaths.home),
                    text: "Continue Shopping",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textAppBlack,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
