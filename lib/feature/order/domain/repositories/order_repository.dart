import '../entities/order_entities.dart';
import '../../../cart/domain/entities/cart_item.dart';

abstract class OrderRepository {
  Future<Order> createOrder({
    required List<CartItem> items,
    required ShippingAddress shippingAddress,
    required String paymentIntentId,
    required Map<String, dynamic> metadata,
  });
  
  Future<List<Order>> getUserOrders();
  Stream<List<Order>> getUserOrdersStream();
  
  Future<List<Order>> getAllOrders();
  Stream<List<Order>> getAllOrdersStream();
  
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<Order?> getOrderById(String orderId);
}
