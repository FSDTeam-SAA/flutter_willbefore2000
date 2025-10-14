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
        DPrint.log("Payment intent created successfully.");
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
          merchantDisplayName: 'SmilesTreats',
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

  // New methods for HomeRevenueReports API

  /// Retrieves a ReportType object by ID (e.g., balance.summary.1)
  static Future<Map<String, dynamic>> getReportType(String reportTypeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reporting/report_types/$reportTypeId'),
        headers: {'Authorization': 'Bearer $secretKey'},
      );

      if (response.statusCode == 200) {
        DPrint.log("Report type retrieved successfully: $reportTypeId");
        return json.decode(response.body);
      } else {
        throw Exception('Failed to retrieve report type: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error retrieving report type: $e');
    }
  }

  /// Creates a report run for the specified report type with given parameters
  static Future<Map<String, dynamic>> createReportRun({
    required String reportType,
    required int intervalStart, // Unix timestamp
    required int intervalEnd, // Unix timestamp
    String? timezone, // Optional, defaults to UTC
    List<String>? columns, // Optional, specify columns to include
    String? currency, // Optional, filter by currency
    String? reportCategory, // Optional, filter by reporting category
  }) async {
    try {
      final body = {
        'report_type': reportType,
        'parameters[interval_start]': intervalStart.toString(),
        'parameters[interval_end]': intervalEnd.toString(),
        if (timezone != null) 'parameters[timezone]': timezone,
        if (currency != null) 'parameters[currency]': currency,
        if (reportCategory != null)
          'parameters[report_category]': reportCategory,
        if (columns != null)
          ...columns.asMap().map(
            (index, column) => MapEntry('parameters[columns][$index]', column),
          ),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/reporting/report_runs'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        DPrint.log("Report run created successfully for $reportType");
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create report run: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating report run: $e');
    }
  }

  /// Retrieves a report run by ID
  static Future<Map<String, dynamic>> getReportRun(String reportRunId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reporting/report_runs/$reportRunId'),
        headers: {'Authorization': 'Bearer $secretKey'},
      );

      if (response.statusCode == 200) {
        DPrint.log("Report run retrieved successfully: $reportRunId");
        return json.decode(response.body);
      } else {
        throw Exception('Failed to retrieve report run: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error retrieving report run: $e');
    }
  }

  /// Retrieves the CSV file contents of a completed report run
  static Future<String> getReportFileContents(String fileUrl) async {
    try {
      final response = await http.get(
        Uri.parse(fileUrl),
        headers: {'Authorization': 'Bearer $secretKey'},
      );

      if (response.statusCode == 200) {
        DPrint.log("Report file contents retrieved successfully.");
        return response.body; // Returns CSV content as a string
      } else {
        throw Exception('Failed to retrieve report file: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error retrieving report file contents: $e');
    }
  }
}
