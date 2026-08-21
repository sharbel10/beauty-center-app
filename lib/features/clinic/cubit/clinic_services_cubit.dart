import 'dart:async';

import 'package:beauty_center_app/features/clinic/cubit/clinic_services_state.dart';
import 'package:beauty_center_app/features/clinic/models/clinic_service_filters.dart';
import 'package:beauty_center_app/features/clinic/repository/clinic_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ClinicServicesCubit extends Cubit<ClinicServicesState> {
  ClinicServicesCubit(this._repository) : super(const ClinicServicesState());

  final ClinicsRepository _repository;
  Timer? _debounceTimer;
  int? _centerId;
  int _requestId = 0;

  Future<void> fetchClinicServices(int centerId) async {
    _centerId = centerId;
    await _fetch();
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final ClinicServiceFilters current = state.filters;
    emit(
      state.copyWith(
        filters: ClinicServiceFilters(
          query: _normalizeQuery(query),
          categoryId: current.categoryId,
          isFeatured: current.isFeatured,
          minPrice: current.minPrice,
          maxPrice: current.maxPrice,
          maxDuration: current.maxDuration,
          sortBy: current.sortBy,
        ),
      ),
    );
    _debounceTimer = Timer(const Duration(milliseconds: 500), _fetch);
  }

  Future<void> applyFilters(ClinicServiceFilters filters) async {
    _debounceTimer?.cancel();
    emit(state.copyWith(filters: filters));
    await _fetch();
  }

  Future<void> resetFilters() async {
    _debounceTimer?.cancel();
    emit(state.copyWith(filters: const ClinicServiceFilters()));
    await _fetch();
  }

  Future<void> _fetch() async {
    final int? centerId = _centerId;
    if (centerId == null) return;
    final int requestId = ++_requestId;
    emit(
      state.copyWith(
        status: ClinicServicesStatus.loading,
        clearServices: true,
        clearMessage: true,
      ),
    );

    final result = await _repository.getClinicServices(
      centerId: centerId,
      filters: state.filters,
    );
    if (isClosed || requestId != _requestId) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ClinicServicesStatus.failure,
          message: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          status: ClinicServicesStatus.success,
          services: response.services,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  static String _normalizeQuery(String query) {
    final String value = query.trim();
    return value.length <= 255 ? value : value.substring(0, 255);
  }
}
