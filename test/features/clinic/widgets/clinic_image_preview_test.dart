import 'package:beauty_center_app/features/clinic/widgets/clinic_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('image becomes previewable only after a successful load', (
    WidgetTester tester,
  ) async {
    late VoidCallback reportLoaded;
    late VoidCallback reportError;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClinicPreviewableImage(
            imageUrl: 'https://example.com/clinic.jpg',
            builder: (VoidCallback onLoaded, VoidCallback onError) {
              reportLoaded = onLoaded;
              reportError = onError;
              return const ColoredBox(
                key: ValueKey<String>('image'),
                color: Colors.blue,
                child: SizedBox(width: 120, height: 120),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('image')));
    await tester.pump();
    expect(find.byType(Dialog), findsNothing);

    reportLoaded();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('image')));
    await tester.pump();
    expect(find.byType(Dialog), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    reportError();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('image')));
    await tester.pump();
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('an empty image path never becomes previewable', (
    WidgetTester tester,
  ) async {
    late VoidCallback reportLoaded;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClinicPreviewableImage(
            imageUrl: '',
            builder: (VoidCallback onLoaded, VoidCallback onError) {
              reportLoaded = onLoaded;
              return const ColoredBox(
                key: ValueKey<String>('placeholder'),
                color: Colors.grey,
                child: SizedBox(width: 120, height: 120),
              );
            },
          ),
        ),
      ),
    );

    reportLoaded();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('placeholder')));
    await tester.pump();

    expect(find.byType(Dialog), findsNothing);
  });
}
