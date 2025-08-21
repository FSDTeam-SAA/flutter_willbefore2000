import 'package:flutter/material.dart';
import '../../../cart/domain/entities/cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

class ShippingAddress {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  const ShippingAddress({
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

  String get fullName => '$firstName $lastName';
  String get fullAddress => '$address, $city, $state $zipCode, $country';
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final ShippingAddress shippingAddress;
  final double subtotal;
  final double tax;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? paymentIntentId;
  final String? trackingNumber;
  final String? orderNumber;
  final DateTime? updatedAt;

  const Order({
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
    this.orderNumber,
    this.updatedAt,
  });

  String get statusText => status.displayName;
  Color get statusColor => status.color;
}
