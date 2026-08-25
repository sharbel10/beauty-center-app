import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  const ReviewModel({
    required this.id,
    required this.centerId,
    required this.appointmentId,
    required this.serviceId,
    this.employeeId,
    required this.rating,
    this.comment,
    this.centerName,
    this.serviceName,
    this.employeeName,
    this.centerImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> center =
        json['center'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> service =
        json['service'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> employee =
        json['employee'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return ReviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      centerId: (json['center_id'] as num?)?.toInt() ?? 0,
      appointmentId: (json['appointment_id'] as num?)?.toInt() ?? 0,
      serviceId: (json['service_id'] as num?)?.toInt() ?? 0,
      employeeId: (json['employee_id'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      centerName: center['name'] as String?,
      serviceName: service['name'] as String?,
      employeeName: employee['name'] as String?,
      centerImageUrl: ApiEndpoints.mediaUrl(center['cover_path'] as String?),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  final int id;
  final int centerId;
  final int appointmentId;
  final int serviceId;
  final int? employeeId;
  final int rating;
  final String? comment;
  final String? centerName;
  final String? serviceName;
  final String? employeeName;
  final String? centerImageUrl;
  final String? createdAt;
  final String? updatedAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    centerId,
    appointmentId,
    serviceId,
    employeeId,
    rating,
    comment,
    centerName,
    serviceName,
    employeeName,
    centerImageUrl,
    createdAt,
    updatedAt,
  ];
}
