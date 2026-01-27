import 'package:flutter_test/flutter_test.dart';
import 'package:smilestreats/core/services/geo_service.dart';

void main() {
  final geoService = GeoService();

  group('GeoService Tests', () {
    test(
      'getStates should return a list of states for a valid country',
      () async {
        // Note: This makes a real network request. In a real project, we'd mock it.
        // But for this environment, we'll try it once.
        final states = await geoService.getStates('United States');
        expect(states, isNotEmpty);
        expect(states, contains('California'));
      },
    );

    test(
      'getCities should return a list of cities for a valid country and state',
      () async {
        final cities = await geoService.getCities(
          'United States',
          'California',
        );
        expect(cities, isNotEmpty);
        expect(cities, contains('Los Angeles'));
      },
    );

    test('getStates should return empty list for invalid country', () async {
      final states = await geoService.getStates('InvalidCountry123');
      expect(states, isEmpty);
    });
  });
}
