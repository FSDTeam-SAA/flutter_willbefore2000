import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../domain/entities/order_entities.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/data/models/cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final ShippingAddressModel shippingAddress;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? paymentIntentId;
  final String? trackingNumber;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
    this.paymentIntentId,
    this.trackingNumber,
    this.updatedAt,
  });

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      userId: order.userId,
      items: order.items,
      shippingAddress: ShippingAddressModel.fromEntity(order.shippingAddress),
      subtotal: order.subtotal,
      tax: order.tax,
      total: order.total,
      status: order.status.name,
      createdAt: order.createdAt,
      estimatedDelivery: order.estimatedDelivery,
      paymentIntentId: order.paymentIntentId,
      trackingNumber: order.trackingNumber,
      updatedAt: order.updatedAt,
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromMap(item))
              .cast<CartItem>()
              .toList() ??
          [],
      shippingAddress: ShippingAddressModel.fromMap(
        data['shippingAddress'] ?? {},
      ),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedDelivery: (data['estimatedDelivery'] as Timestamp?)?.toDate(),
      paymentIntentId: data['paymentIntentId'],
      trackingNumber: data['trackingNumber'],
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items
          .map((item) => CartItemModel.fromCartItem(item).toMap())
          .toList(),
      'shippingAddress': shippingAddress.toMap(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'estimatedDelivery': estimatedDelivery != null
          ? Timestamp.fromDate(estimatedDelivery!)
          : null,
      'paymentIntentId': paymentIntentId,
      'trackingNumber': trackingNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Order toEntity() {
    return Order(
      id: id,
      userId: userId,
      items: items,
      shippingAddress: shippingAddress.toEntity(),
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => OrderStatus.pending,
      ),
      createdAt: createdAt,
      estimatedDelivery: estimatedDelivery,
      paymentIntentId: paymentIntentId,
      trackingNumber: trackingNumber,
      updatedAt: updatedAt,
    );
  }
}

class ShippingAddressModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  const ShippingAddressModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory ShippingAddressModel.fromEntity(ShippingAddress address) {
    return ShippingAddressModel(
      firstName: address.firstName,
      lastName: address.lastName,
      email: address.email,
      phoneNumber: address.phoneNumber,
      address: address.address,
      city: address.city,
      state: address.state,
      zipCode: address.zipCode,
      country: address.country,
    );
  }

  factory ShippingAddressModel.fromMap(Map<String, dynamic> map) {
    return ShippingAddressModel(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      country: map['country'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }

  ShippingAddress toEntity() {
    return ShippingAddress(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
    );
  }
}
