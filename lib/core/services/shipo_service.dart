import 'dart:convert';
import 'package:flutx_core/flutx_core.dart';
import 'package:http/http.dart' as http;

class ShippoService {
  static const String baseUrl = 'https://api.goshippo.com';
  static const String apiToken =
      'shippo_test_763c1b35dfa914e4695ebd890a960256bf0345d4';

  Future<Map<String, dynamic>?> createAddress({
    required String name,
    String? company,
    required String street1,
    String? street2,
    required String city,
    required String state,
    required String zip,
    required String country,
    String? phone,
    String? email,
    bool? isResidential,
    String? metadata,
  }) async {
    final url = Uri.parse('$baseUrl/addresses/');
    final headers = {
      'Authorization': 'ShippoToken $apiToken',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'name': name,
      if (company != null) 'company': company,
      'street1': street1,
      if (street2 != null) 'street2': street2,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country, // ISO2 code, e.g., 'US'
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (isResidential != null) 'is_residential': isResidential,
      if (metadata != null) 'metadata': metadata,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        // Success for POST
        return jsonDecode(response.body);
      } else {
        DPrint.error('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      DPrint.error('Exception: $e');
      return null;
    }
  }
}
