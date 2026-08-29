import 'package:beauty_center_app/features/explore/models/centers_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CentersResponse pagination', () {
    test('reads pagination metadata from the response root', () {
      final CentersResponse response = CentersResponse.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{'centers': <dynamic>[]},
          'meta': <String, dynamic>{
            'current_page': 1,
            'last_page': 3,
            'per_page': 10,
            'total': 24,
          },
        },
      );

      expect(response.meta.hasNextPage, isTrue);
      expect(response.meta.nextPage, 2);
    });

    test('reads pagination metadata nested inside data', () {
      final CentersResponse response = CentersResponse.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'centers': <dynamic>[],
            'meta': <String, dynamic>{
              'current_page': 1,
              'last_page': 2,
              'per_page': 10,
              'total': 12,
            },
          },
        },
      );

      expect(response.meta.hasNextPage, isTrue);
      expect(response.meta.nextPage, 2);
    });
  });
}
