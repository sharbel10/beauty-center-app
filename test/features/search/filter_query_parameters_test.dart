import 'package:beauty_center_app/features/clinic/models/clinic_service_filters.dart';
import 'package:beauty_center_app/features/explore/models/center_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('search filter query parameters', () {
    test('center filters use q and include all supported values', () {
      const CenterFilters filters = CenterFilters(
        categoryId: 2,
        city: 'Damascus',
        area: 'Mazzeh',
        governorate: 'damascus',
        isFeatured: true,
        requiresDeposit: false,
        minRating: 3.5,
        minPrice: 50,
        maxPrice: 900,
        latitude: 33.5,
        longitude: 36.2,
        radiusKm: 20,
        sortBy: 'nearest',
      );

      final Map<String, dynamic> query = filters.toQueryParameters(
        query: 'spa',
        page: 2,
      );
      expect(query['q'], 'spa');
      expect(query.containsKey('search'), isFalse);
      expect(query['requires_deposit'], isFalse);
      expect(query['sort_by'], 'nearest');
      expect(query['page'], 2);
      expect(query['per_page'], CenterFilters.defaultPerPage);
    });

    test('center service filters omit empty values', () {
      const ClinicServiceFilters filters = ClinicServiceFilters(
        query: ' facial ',
        categoryId: 7,
        isFeatured: true,
        minPrice: 10,
        maxPrice: 80,
        maxDuration: 60,
        sortBy: 'duration',
      );

      expect(filters.toQueryParameters(), <String, dynamic>{
        'q': 'facial',
        'category_id': 7,
        'is_featured': true,
        'min_price': 10.0,
        'max_price': 80.0,
        'max_duration': 60,
        'sort_by': 'duration',
      });
    });
  });
}
