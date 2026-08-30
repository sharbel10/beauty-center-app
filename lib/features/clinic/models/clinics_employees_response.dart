import 'package:equatable/equatable.dart';

class ClinicEmployeesResponse extends Equatable {
  const ClinicEmployeesResponse({
    required this.success,
    required this.employees,
  });

  factory ClinicEmployeesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> employeesList =
        json['data']['employees'] as List<dynamic>? ?? <dynamic>[];
    return ClinicEmployeesResponse(
      success: json['success'] as bool? ?? true,
      employees: employeesList
          .map(
            (dynamic item) =>
                ClinicEmployeeItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final bool success;
  final List<ClinicEmployeeItem> employees;

  @override
  List<Object?> get props => [success, employees];
}

class ClinicEmployeeItem extends Equatable {
  const ClinicEmployeeItem({
    required this.id,
    required this.centerId,
    required this.name,
    required this.specialization,
    required this.bio,
    required this.avatarPath,
    required this.avatarUrl,
    required this.isBookable,
  });

  factory ClinicEmployeeItem.fromJson(Map<String, dynamic> json) {
    return ClinicEmployeeItem(
      id: json['id'] as int? ?? 0,
      centerId: json['center_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatarPath: json['avatar_path'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      isBookable: json['is_bookable'] as bool? ?? false,
    );
  }

  final int id;
  final int centerId;
  final String name;
  final String specialization;
  final String bio;
  final String avatarPath;
  final String avatarUrl;
  final bool isBookable;

  @override
  List<Object?> get props => [
    id,
    centerId,
    name,
    specialization,
    bio,
    avatarPath,
    avatarUrl,
    isBookable,
  ];
}
