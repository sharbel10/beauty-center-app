import 'package:equatable/equatable.dart';

class ClinicPortfolioResponse extends Equatable {
  const ClinicPortfolioResponse({
    required this.success,
    required this.portfolio,
  });

  factory ClinicPortfolioResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return ClinicPortfolioResponse(
      success: json['success'] as bool? ?? true,
      portfolio: (data['portfolio'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) =>
                ClinicPortfolioItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final bool success;
  final List<ClinicPortfolioItem> portfolio;

  @override
  List<Object?> get props => [success, portfolio];
}

class ClinicPortfolioItem extends Equatable {
  const ClinicPortfolioItem({
    required this.id,
    required this.centerId,
    required this.serviceId,
    required this.employeeId,
    required this.beforeImagePath,
    required this.beforeImageUrl,
    required this.afterImagePath,
    required this.afterImageUrl,
    required this.caption,
  });

  factory ClinicPortfolioItem.fromJson(Map<String, dynamic> json) {
    return ClinicPortfolioItem(
      id: json['id'] as int? ?? 0,
      centerId: json['center_id'] as int? ?? 0,
      serviceId: json['service_id'] as int? ?? 0,
      employeeId: json['employee_id'] as int? ?? 0,
      beforeImagePath: _readString(json['before_image_path']),
      beforeImageUrl: _readString(json['before_image_url']),
      afterImagePath: _readString(json['after_image_path']),
      afterImageUrl: _readString(json['after_image_url']),
      caption: json['caption'] as String? ?? '',
    );
  }

  final int id;
  final int centerId;
  final int serviceId;
  final int employeeId;
  final String beforeImagePath;
  final String beforeImageUrl;
  final String afterImagePath;
  final String afterImageUrl;
  final String caption;

  @override
  List<Object?> get props => [
    id,
    centerId,
    serviceId,
    employeeId,
    beforeImagePath,
    beforeImageUrl,
    afterImagePath,
    afterImageUrl,
    caption,
  ];
}

String _readString(dynamic value) => value?.toString().trim() ?? '';
