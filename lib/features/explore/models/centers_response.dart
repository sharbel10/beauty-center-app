import 'package:beauty_center_app/features/explore/models/pagination_meta.dart';
import 'package:beauty_center_app/features/home/models/clinic_center.dart';
import 'package:equatable/equatable.dart';

class CentersResponse extends Equatable {
  const CentersResponse({
    required this.success,
    required this.centers,
    required this.meta,
  });

  factory CentersResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? data = json['data'] as Map<String, dynamic>?;

    return CentersResponse(
      success: json['success'] as bool? ?? true,
      centers: (data?['centers'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) =>
                ClinicCenter.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>?),
    );
  }

  final bool success;
  final List<ClinicCenter> centers;
  final PaginationMeta meta;

  @override
  List<Object?> get props => [success, centers, meta];
}
