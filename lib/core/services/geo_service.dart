import 'dart:convert';
import 'package:http/http.dart' as http;

class GeoService {
  static const String _baseUrl = 'https://countriesnow.space/api/v0.1';

  /// Fetches ALL cities for a given country name.
  Future<List<String>> getAllCities(String countryName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/countries/cities/q?country=$countryName'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          final List<dynamic> citiesList = data['data'];
          return citiesList.map((c) => c.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetches the list of states for a given country name.
  Future<List<String>> getStates(String countryName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/countries/states/q?country=$countryName'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          final List<dynamic> statesList = data['data']['states'];
          return statesList.map((s) => s['name'].toString()).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetches the list of cities for a given country and state name.
  Future<List<String>> getCities(String countryName, String stateName) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/countries/state/cities/q?country=$countryName&state=$stateName',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          final List<dynamic> citiesList = data['data'];
          return citiesList.map((c) => c.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
