// user order_remote_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/order_entities.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<void> createOrder(Order order);
  Future<List<Order>> getUserOrders(String userId);
  Stream<List<Order>> getUserOrdersStream(String userId);
  Future<List<Order>> getAllOrders();
  Stream<List<Order>> getAllOrdersStream();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> updateOrderPhoneNumber(String orderId, String phoneNumber);
  Future<Order?> getOrderById(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore;

  OrderRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createOrder(Order order) async {
    try {
      final orderModel = OrderModel.fromEntity(order);
      final batch = _firestore.batch();

      // Save in main orders collection for admin queries
      final mainOrderRef = _firestore.collection('orders').doc(order.id);
      batch.set(mainOrderRef, orderModel.toFirestore());

      // Save in user subcollection for efficient user queries
      final userOrderRef = _firestore
          .collection('users')
          .doc(order.userId)
          .collection('orders')
          .doc(order.id);
      batch.set(userOrderRef, orderModel.toFirestore());

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  @override
  Stream<List<Order>> getUserOrdersStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc).toEntity())
              .toList(),
        );
  }

  @override
  Future<List<Order>> getAllOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get all orders: $e');
    }
  }

  @override
  Stream<List<Order>> getAllOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc).toEntity())
              .toList(),
        );
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final batch = _firestore.batch();

      // Update in main orders collection
      final mainOrderRef = _firestore.collection('orders').doc(orderId);
      batch.update(mainOrderRef, {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Find and update in user subcollection
      // First get the order to find the userId
      final orderDoc = await mainOrderRef.get();
      if (orderDoc.exists) {
        final userId = orderDoc.data()?['userId'];
        if (userId != null) {
          final userOrderRef = _firestore
              .collection('users')
              .doc(userId)
              .collection('orders')
              .doc(orderId);
          batch.update(userOrderRef, {
            'status': status.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<void> updateOrderPhoneNumber(
    String orderId,
    String phoneNumber,
  ) async {
    try {
      final batch = _firestore.batch();

      // Update in main orders collection
      final mainOrderRef = _firestore.collection('orders').doc(orderId);
      batch.update(mainOrderRef, {
        'shippingAddress.phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Find and update in user subcollection
      final orderDoc = await mainOrderRef.get();
      if (orderDoc.exists) {
        final userId = orderDoc.data()?['userId'];
        if (userId != null) {
          final userOrderRef = _firestore
              .collection('users')
              .doc(userId)
              .collection('orders')
              .doc(orderId);
          batch.update(userOrderRef, {
            'shippingAddress.phoneNumber': phoneNumber,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update order phone number: $e');
    }
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromFirestore(doc).toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }
}

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSourceImpl();
});
