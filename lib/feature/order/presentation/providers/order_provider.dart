import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutx_core/flutx_core.dart';
import '../../data/sources/order_remote_data_source.dart';
import '../../domain/entities/order_entities.dart';
import '../../domain/repositories/order_repository.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../../cart/domain/entities/cart_item.dart';

// Add these missing definitions
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    ref.watch(orderRemoteDataSourceProvider),
    auth: FirebaseAuth.instance,
  );
});

// Add extensions for Order class if missing
extension OrderExtensions on Order {
  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderRepository _repository;

  OrderNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadOrders();
    _listenToOrderChanges();
  }

  void _listenToOrderChanges() {
    _repository.getUserOrdersStream().listen(
      (orders) {
        state = AsyncValue.data(orders);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _repository.getUserOrders();
      DPrint.log('Loaded ${orders.length} orders');
      state = AsyncValue.data(orders);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<Order> createOrder({
    required List<CartItem> items,
    required ShippingAddress shippingAddress,
    required String paymentIntentId,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final order = await _repository.createOrder(
        items: items,
        shippingAddress: shippingAddress,
        paymentIntentId: paymentIntentId,
        metadata: metadata,
      );

      // State will be updated automatically via stream listener
      return order;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _repository.updateOrderStatus(orderId, status);
      // State will be updated automatically via stream listener
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }


}

class AdminOrderNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderRepository _repository;

  AdminOrderNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadAllOrders();
    _listenToAllOrderChanges();
  }

  void _listenToAllOrderChanges() {
    _repository.getAllOrdersStream().listen(
      (orders) {
        state = AsyncValue.data(orders);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  Future<void> _loadAllOrders() async {
    try {
      final orders = await _repository.getAllOrders();
      state = AsyncValue.data(orders);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _repository.updateOrderStatus(orderId, status);
      // State will be updated automatically via stream listener
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<Order>>>((ref) {
      final repository = ref.watch(orderRepositoryProvider);
      return OrderNotifier(repository);
    });

final adminOrderProvider =
    StateNotifierProvider<AdminOrderNotifier, AsyncValue<List<Order>>>((ref) {
      final repository = ref.watch(orderRepositoryProvider);
      return AdminOrderNotifier(repository);
    });
