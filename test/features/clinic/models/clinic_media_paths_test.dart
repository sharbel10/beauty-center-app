import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_employees_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_portfolio_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:beauty_center_app/features/home/models/advertisement.dart';
import 'package:beauty_center_app/features/reviews/models/review_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clinic details accepts full media URL fields', () {
    final ClinicDetailsResponse response = ClinicDetailsResponse.fromJson(
      <String, dynamic>{
        'data': <String, dynamic>{
          'center': <String, dynamic>{
            'cover_url': 'https://cdn.example.com/cover.jpg',
            'cover_path': 'centers/cover.jpg',
            'images': <Map<String, dynamic>>[
              <String, dynamic>{
                'image_url': 'https://cdn.example.com/interior.jpg',
                'image_path': 'centers/interior.jpg',
              },
            ],
          },
        },
      },
    );

    expect(response.center.coverUrl, 'https://cdn.example.com/cover.jpg');
    expect(response.center.coverPath, 'centers/cover.jpg');
    expect(
      response.center.images.single.imageUrl,
      'https://cdn.example.com/interior.jpg',
    );
    expect(response.center.images.single.imagePath, 'centers/interior.jpg');
  });

  test(
    'clinic details keeps a missing URL empty instead of using its path',
    () {
      final ClinicDetailsResponse response = ClinicDetailsResponse.fromJson(
        <String, dynamic>{
          'data': <String, dynamic>{
            'center': <String, dynamic>{
              'cover_url': ' ',
              'cover_path': 'centers/cover.jpg',
              'images': <Map<String, dynamic>>[
                <String, dynamic>{'image_path': 'centers/interior.jpg'},
              ],
            },
          },
        },
      );

      expect(response.center.coverUrl, isEmpty);
      expect(response.center.images.single.imageUrl, isEmpty);
      expect(response.center.coverPath, 'centers/cover.jpg');
      expect(response.center.images.single.imagePath, 'centers/interior.jpg');
    },
  );

  test('portfolio keeps URL fields separate from path fields', () {
    final ClinicPortfolioResponse response = ClinicPortfolioResponse.fromJson(
      <String, dynamic>{
        'data': <String, dynamic>{
          'portfolio': <Map<String, dynamic>>[
            <String, dynamic>{
              'before_image_url': 'https://cdn.example.com/before.jpg',
              'before_image_path': 'portfolio/before.jpg',
              'after_image_path': 'portfolio/after.jpg',
            },
          ],
        },
      },
    );

    expect(
      response.portfolio.single.beforeImageUrl,
      'https://cdn.example.com/before.jpg',
    );
    expect(response.portfolio.single.beforeImagePath, 'portfolio/before.jpg');
    expect(response.portfolio.single.afterImageUrl, isEmpty);
    expect(response.portfolio.single.afterImagePath, 'portfolio/after.jpg');
  });

  test('employees and services parse their URL fields', () {
    final ClinicEmployeeItem employee =
        ClinicEmployeeItem.fromJson(<String, dynamic>{
          'avatar_path': 'employees/avatar.jpg',
          'avatar_url': 'https://cdn.example.com/avatar.jpg',
        });
    final ClinicServiceItem service = ClinicServiceItem.fromJson(
      <String, dynamic>{
        'image_path': 'services/service.jpg',
        'image_url': 'https://cdn.example.com/service.jpg',
        'category': <String, dynamic>{
          'icon_path': 'categories/category.png',
          'icon_url': 'https://cdn.example.com/category.png',
        },
      },
    );

    expect(employee.avatarUrl, 'https://cdn.example.com/avatar.jpg');
    expect(service.imageUrl, 'https://cdn.example.com/service.jpg');
    expect(service.category.iconUrl, 'https://cdn.example.com/category.png');
  });

  test('bookings, reviews, and ads use URL response fields', () {
    final AppointmentModel appointment = AppointmentModel.fromJson(
      <String, dynamic>{
        'center': <String, dynamic>{
          'cover_path': 'centers/cover.jpg',
          'cover_url': 'https://cdn.example.com/cover.jpg',
        },
      },
    );
    final ReviewModel review = ReviewModel.fromJson(<String, dynamic>{
      'center': <String, dynamic>{
        'cover_path': 'centers/cover.jpg',
        'cover_url': 'https://cdn.example.com/cover.jpg',
      },
    });
    final Advertisement advertisement =
        Advertisement.fromJson(<String, dynamic>{
          'id': 1,
          'title': 'Ad',
          'image_path': 'ads/ad.jpg',
          'image_url': 'https://cdn.example.com/ad.jpg',
        });

    expect(appointment.imageUrl, 'https://cdn.example.com/cover.jpg');
    expect(review.centerImageUrl, 'https://cdn.example.com/cover.jpg');
    expect(advertisement.imageUrl, 'https://cdn.example.com/ad.jpg');
  });
}
