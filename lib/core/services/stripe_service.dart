import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/constants/stripe_secret_key.dart';

class StripeService {
  static const String _baseUrl = 'https://api.stripe.com/v1';
  static const String publishableKey = stripePublishableKey;
  static const String secretKey = stripeSecretKey;
  
  static Future<void> init() async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  static Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency,
          'automatic_payment_methods[enabled]': 'true',
          if (metadata != null)
            ...metadata.map(
              (key, value) => MapEntry('metadata[$key]', value.toString()),
            ),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  static Future<bool> confirmPayment({
    required String clientSecret,
    required PaymentMethodParams paymentMethodParams,
  }) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: paymentMethodParams,
      );
      return true;
    } catch (e) {
      DPrint.error('Payment confirmation error: $e');
      return false;
    }
  }

  static Future<bool> processPayment({
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Convert amount to cents
      final amountInCents = (amount * 100).round().toString();

      // Create payment intent
      final paymentIntent = await createPaymentIntent(
        amount: amountInCents,
        currency: currency,
        metadata: metadata,
      );

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Your Store Name',
          style: ThemeMode.system,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      DPrint.error('Payment processing error: $e');
      return false;
    }
  }
}
