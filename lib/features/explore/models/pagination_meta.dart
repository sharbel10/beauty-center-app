import 'package:equatable/equatable.dart';

class PaginationMeta extends Equatable {
  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: 0,
        total: 0,
      );
    }

    return PaginationMeta(
      currentPage: _toInt(json['current_page']) ?? 1,
      lastPage: _toInt(json['last_page']) ?? 1,
      perPage: _toInt(json['per_page']) ?? 0,
      total: _toInt(json['total']) ?? 0,
    );
  }

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  bool get hasNextPage => currentPage < lastPage;
  int get nextPage => currentPage + 1;

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}
