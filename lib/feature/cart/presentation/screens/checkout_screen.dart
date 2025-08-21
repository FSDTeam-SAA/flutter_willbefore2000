import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';
import 'package:smilestreats/core/constants/app_colors.dart';
import 'package:smilestreats/core/routes/route_endpoint.dart';
import 'package:smilestreats/core/utils/extensions/button_extensions.dart';
import '../../../../core/constants/app_icons_const.dart';
import '../../../../core/services/stripe_service.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../order/domain/entities/order_entities.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../providers/checkout_form_proivder.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final formState = ref.watch(checkoutFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: cartState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartState.errorMessage != null
          ? Center(child: Text('Error: ${cartState.errorMessage}'))
          : cartState.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildShippingSection(ref, formState),
                  const SizedBox(height: 24),
                  _buildPaymentSection(),
                  const SizedBox(height: 32),
                  _buildContinueButton(
                    ref,
                    cartState.items,
                    cartState.total,
                    formState,
                    // context
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildShippingSection(WidgetRef ref, CheckoutFormState formState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryLaurel,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  ref: ref,
                  field: 'firstName',
                  label: 'First Name',
                  initialValue: formState.firstName,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  ref: ref,
                  field: 'lastName',
                  label: 'Last Name',
                  initialValue: formState.lastName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  ref: ref,
                  field: 'email',
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  initialValue: formState.email,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  ref: ref,
                  field: 'phoneNumber',
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  initialValue: formState.phoneNumber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            ref: ref,
            field: 'address',
            label: 'Address',
            initialValue: formState.address,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  ref: ref,
                  field: 'city',
                  label: 'City',
                  initialValue: formState.city,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  ref: ref,
                  field: 'state',
                  label: 'State',
                  initialValue: formState.state,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  ref: ref,
                  field: 'zipCode',
                  label: 'ZIP Code',
                  initialValue: formState.zipCode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Country',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: formState.country,
                isExpanded: true,
                items: ['United States', 'Canada', 'United Kingdom']
                    .map(
                      (country) => DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(checkoutFormProvider.notifier)
                        .updateField('country', value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pay',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            // padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: 'stripe',
                  groupValue: 'stripe',
                  onChanged: (value) {},
                  activeColor: Colors.blue,
                ),
                const Text(
                  'Pay With Stripe',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                const Spacer(),
                Image.asset(AssetsPath.stripeLogo, height: 40, width: 40),
                Gap.w8,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required WidgetRef ref,
    required String field,
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.iconDeselectedColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: TextFormField(
            initialValue: initialValue,
            keyboardType: keyboardType,
            onChanged: (value) {
              ref.read(checkoutFormProvider.notifier).updateField(field, value);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4, // Reduced vertical padding to fit in 30 height
              ),
              isDense: true, // This reduces the overall height
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.iconDeselectedColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.iconDeselectedColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(
                  color: AppColors.iconDeselectedColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(
    WidgetRef ref,
    List<CartItem> cartItems,
    double total,
    CheckoutFormState formState,
  ) {
    return SizedBox(
      width: 181,
      child: ref.context.primaryButton(
        onPressed: () {
          if (formState.isValid) {
            _processPayment(ref, cartItems, total, formState);
          }
        },
        text: 'Continue to Payment',
      ),
    );
  }

  Future<void> _processPayment(
    WidgetRef ref,
    List<CartItem> cartItems,
    double total,
    CheckoutFormState formState,
  ) async {
    try {
      // Process payment with Stripe
      final success = await StripeService.processPayment(
        amount: total,
        currency: 'usd',
        metadata: {
          'customer_email': formState.email,
          'order_items': cartItems.length.toString(),
        },
      );

      if (success) {
        // Create shipping address using form state
        final shippingAddress = ShippingAddress(
          firstName: formState.firstName,
          lastName: formState.lastName,
          email: formState.email,
          phoneNumber: formState.phoneNumber,
          address: formState.address,
          city: formState.city,
          state: formState.state,
          zipCode: formState.zipCode,
          country: formState.country,
        );

        // Create order
        final order = await ref
            .read(orderProvider.notifier)
            .createOrder(
              items: cartItems,
              shippingAddress: shippingAddress,
              paymentIntentId: 'pi_${DateTime.now().millisecondsSinceEpoch}',
            );

        // Clear cart and form
        await ref.read(cartProvider.notifier).clearCart();
        ref.read(checkoutFormProvider.notifier).reset();

        // Navigate to success page
        if (ref.context.mounted) {
          GoRouter.of(ref.context).go(RoutePaths.orderConfirm, extra: order);
        }
      }
    } catch (e) {
      // Handle error
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text('Payment error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
