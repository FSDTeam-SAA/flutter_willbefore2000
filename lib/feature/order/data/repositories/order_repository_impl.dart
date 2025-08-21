import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order_entities.dart';
import '../../domain/repositories/order_repository.dart';
import '../sources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;
  final FirebaseAuth _auth;

  OrderRepositoryImpl(
    this._remoteDataSource, {
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Order> createOrder({
    required List<CartItem> items,
    required ShippingAddress shippingAddress,
    required String paymentIntentId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final tax = subtotal * 0.0; // No tax for now
    final total = subtotal + tax;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.uid,
      items: items,
      shippingAddress: shippingAddress,
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: OrderStatus.pending, // Default status is pending
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
      paymentIntentId: paymentIntentId,
      orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
    );

    await _remoteDataSource.createOrder(order);
    return order;
  }

  @override
  Future<List<Order>> getUserOrders() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return await _remoteDataSource.getUserOrders(user.uid);
  }

  @override
  Stream<List<Order>> getUserOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Stream.error('User not authenticated');
    }
    return _remoteDataSource.getUserOrdersStream(user.uid);
  }

  @override
  Future<List<Order>> getAllOrders() async {
    return await _remoteDataSource.getAllOrders();
  }

  @override
  Stream<List<Order>> getAllOrdersStream() {
    return _remoteDataSource.getAllOrdersStream();
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _remoteDataSource.updateOrderStatus(orderId, status);
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    return await _remoteDataSource.getOrderById(orderId);
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource);
});
