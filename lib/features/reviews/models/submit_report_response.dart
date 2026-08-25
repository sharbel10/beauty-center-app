import 'package:equatable/equatable.dart';

class SubmitReportResponse extends Equatable {
  const SubmitReportResponse({
    required this.success,
    required this.message,
    this.reportId,
  });

  factory SubmitReportResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return SubmitReportResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      reportId: (data['id'] as num?)?.toInt() ??
          (data['report_id'] as num?)?.toInt(),
    );
  }

  final bool success;
  final String message;
  final int? reportId;

  @override
  List<Object?> get props => <Object?>[success, message, reportId];
}
