import 'dart:convert';
import 'package:flutx_core/flutx_core.dart';
import 'package:http/http.dart' as http;
import 'package:smilestreats/core/constants/shippo_key.dart';

class ShippoService {
  static const String baseUrl = 'https://api.goshippo.com';
  static const String apiToken = shippoTestKey;

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
      'validate': true,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 400) {
        // Success for POST or Validation Error
        return jsonDecode(response.body);
      } else {
        DPrint.error('Error: ${response.statusCode} - ${response.body}');
        return {
          'status': 'error',
          'statusCode': response.statusCode,
          'message': response.body,
        };
      }
    } catch (e) {
      DPrint.error('Exception: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createShipment({
    required String addressToId,
    double weight = 1.0, // in pounds
    String massUnit = 'lb',
    double length = 5,
    double width = 5,
    double height = 5,
    String distanceUnit = 'in',
  }) async {
    final url = Uri.parse('$baseUrl/shipments/');
    final headers = {
      'Authorization': 'ShippoToken $apiToken',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'address_from': {
        'name': 'Smile Treats',
        'street1': '852 S Carson St',
        'city': 'Carson',
        'state': 'CA',
        'zip': '90745',
        'country': 'US',
      },
      'address_to': addressToId,
      'parcels': [
        {
          'length': length.toString(),
          'width': width.toString(),
          'height': height.toString(),
          'distance_unit': distanceUnit,
          'weight': weight.toString(),
          'mass_unit': massUnit,
        },
      ],
      'async': false,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        DPrint.error(
          'Error creating shipment: ${response.statusCode} - ${response.body}',
        );
        return {
          'status': 'error',
          'statusCode': response.statusCode,
          'message': response.body,
        };
      }
    } catch (e) {
      DPrint.error('Exception creating shipment: $e');
      return null;
    }
  }
}
