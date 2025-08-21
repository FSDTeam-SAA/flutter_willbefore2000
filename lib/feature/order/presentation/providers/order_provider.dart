import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order_entities.dart';
import '../../../cart/domain/entities/cart_item.dart';

class OrderNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  OrderNotifier() : super(const AsyncValue.loading()) {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      // Simulate loading orders from Firebase
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock orders for demonstration
      final orders = <Order>[
        Order(
          id: '1',
          userId: 'user1',
          items: [],
          shippingAddress: ShippingAddress(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            phoneNumber: '+1234567890',
            address: '123 Main St',
            city: 'New York',
            state: 'NY',
            zipCode: '10001',
            country: 'United States',
          ),
          subtotal: 239.96,
          tax: 0.00,
          total: 239.96,
          status: OrderStatus.delivered,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
        ),
      ];
      
      state = AsyncValue.data(orders);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Order> createOrder({
    required List<CartItem> items,
    required ShippingAddress shippingAddress,
    required String paymentIntentId,
  }) async {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final tax = subtotal * 0.0; // No tax for now
    final total = subtotal + tax;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id', // Get from auth
      items: items,
      shippingAddress: shippingAddress,
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
      paymentIntentId: paymentIntentId,
    );

    // Add to Firebase here
    
    // Update local state
    final currentOrders = state.value ?? [];
    state = AsyncValue.data([order, ...currentOrders]);
    
    return order;
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final currentOrders = state.value ?? [];
    final updatedOrders = currentOrders.map((order) {
      if (order.id == orderId) {
        return Order(
          id: order.id,
          userId: order.userId,
          items: order.items,
          shippingAddress: order.shippingAddress,
          subtotal: order.subtotal,
          tax: order.tax,
          total: order.total,
          status: status,
          createdAt: order.createdAt,
          estimatedDelivery: order.estimatedDelivery,
          paymentIntentId: order.paymentIntentId,
          trackingNumber: order.trackingNumber,
        );
      }
      return order;
    }).toList();
    
    state = AsyncValue.data(updatedOrders);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, AsyncValue<List<Order>>>(
  (ref) => OrderNotifier(),
);
