import 'package:beauty_center_app/features/home/models/home_data.dart';
import 'package:equatable/equatable.dart';

class HomeResponse extends Equatable {
  const HomeResponse({required this.success, this.data});

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      success: json['success'] as bool? ?? true,
      data: json['data'] != null
          ? HomeData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool success;
  final HomeData? data;

  @override
  List<Object?> get props => [success, data];
}
