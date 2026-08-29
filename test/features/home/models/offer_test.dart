import 'package:beauty_center_app/features/home/models/offer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Offer.fromJson', () {
    test('reads the directly associated service id', () {
      final Offer offer = Offer.fromJson(<String, dynamic>{
        'id': 1,
        'center_id': 10,
        'service_id': 25,
        'title': 'Facial offer',
        'discount_type': 'percentage',
        'discount_value': 20,
      });

      expect(offer.serviceId, 25);
    });

    test('reads the first associated service from a services relation', () {
      final Offer offer = Offer.fromJson(<String, dynamic>{
        'id': 1,
        'center_id': 10,
        'title': 'Facial offer',
        'discount_type': 'percentage',
        'discount_value': 20,
        'services': <Map<String, dynamic>>[
          <String, dynamic>{'id': '25'},
        ],
      });

      expect(offer.serviceId, 25);
    });
  });
}
