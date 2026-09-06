import 'package:beauty_center_app/features/bookings/components/appointment_card.dart';
import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:beauty_center_app/features/home/models/home_clinic_ui.dart';
import 'package:beauty_center_app/features/home/widgets/nearby_clinic_card.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'nearby center card does not overflow on a narrow Arabic screen',
    (WidgetTester tester) async {
      await _setNarrowScreen(tester);

      await _pumpArabicWidget(
        tester,
        NearbyClinicCard(
          clinic: const HomeClinicUiModel(
            id: 1,
            imageUrl: '',
            name: 'مركز أورورا المتخصص للعناية بالبشرة والليزر',
            location: 'دمشق، المزة، شارع طويل جداً لاختبار حدود البطاقة',
            distance: '12.5 km',
            tags: <String>[],
            rating: 4.8,
            ratingsCount: 128,
            isFeatured: true,
            description:
                'مركز متخصص يقدم مجموعة واسعة جداً من العلاجات التجميلية',
            city: 'دمشق',
            area: 'المزة الغربية',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('appointment cards do not overflow on a narrow Arabic screen', (
    WidgetTester tester,
  ) async {
    await _setNarrowScreen(tester);
    final DateTime startsAt = DateTime(2026, 8, 30, 14, 30);
    final AppointmentModel appointment = AppointmentModel(
      id: 1,
      clinicName: 'مركز أورورا المتخصص للعناية بالبشرة والليزر',
      serviceName: 'ميكرونيدلينغ مع سيروم عوامل النمو للبشرة',
      date: 'الأحد، 30 أغسطس 2026',
      time: '02:30 مساءً',
      status: AppointmentStatus.confirmed,
      statusLabel: 'مؤكد',
      imageUrl: '',
      startsAt: startsAt,
      endsAt: startsAt.add(const Duration(hours: 1)),
      total: 300000,
      depositRequired: 0,
      depositPaid: 0,
      depositDue: 0,
      paymentStatus: 'paid',
      centerId: 1,
      serviceId: 10,
    );

    await _pumpArabicWidget(
      tester,
      Column(
        children: <Widget>[
          AppointmentCard(appointment: appointment),
          const SizedBox(height: 16),
          AppointmentCard(appointment: appointment, isPast: true),
        ],
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

Future<void> _setNarrowScreen(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(320, 700);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _pumpArabicWidget(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.15)),
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
