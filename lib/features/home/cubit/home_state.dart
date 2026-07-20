import 'package:beauty_center_app/features/home/models/home_data.dart';
import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.data,
    this.message,
  });

  final HomeStatus status;
  final HomeData? data;
  final String? message;

  bool get isLoading => status == HomeStatus.loading;
  bool get hasData => data != null;

  HomeState copyWith({
    HomeStatus? status,
    HomeData? data,
    String? message,
    bool clearData = false,
    bool clearMessage = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: clearData ? null : (data ?? this.data),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, data, message];
}
