import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiEndpoints.mediaUrl', () {
    test('keeps an absolute media URL unchanged', () {
      const String url = 'https://cdn.example.com/centers/cover.jpg';

      expect(ApiEndpoints.mediaUrl(url), url);
    });

    test('adds the storage base URL to a relative path', () {
      expect(
        ApiEndpoints.mediaUrl('centers/cover.jpg'),
        'https://lumina.kefanox.com/storage/centers/cover.jpg',
      );
    });

    test('does not duplicate an existing storage path segment', () {
      expect(
        ApiEndpoints.mediaUrl('/storage/centers/cover.jpg'),
        'https://lumina.kefanox.com/storage/centers/cover.jpg',
      );
    });

    test('returns an empty URL for missing media', () {
      expect(ApiEndpoints.mediaUrl(null), isEmpty);
      expect(ApiEndpoints.mediaUrl('  '), isEmpty);
    });
  });
}
