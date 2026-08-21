import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_employees_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_offers_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_portfolio_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinic_service_filters.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class ClinicsRepository extends BaseRepository {
  ClinicsRepository(super.dioClient);

  Future<Either<Failure, ClinicDetailsResponse>> getClinicDetails({
    required int centerId,
  }) {
    return callApiWithErrorParser(
      dio.get('${ApiEndpoints.centers}/$centerId'),
      ClinicDetailsResponse.fromJson,
    );
  }

  Future<Either<Failure, ClinicEmployeesResponse>> getClinicEmployees({
    required int centerId,
    int? serviceId,
  }) {
    final Map<String, dynamic> queryParams = {};
    if (serviceId != null) {
      queryParams['service_id'] = serviceId;
    }

    return callApiWithErrorParser(
      dio.get(
        '${ApiEndpoints.centers}/$centerId/employees',
        queryParameters: queryParams,
      ),
      ClinicEmployeesResponse.fromJson,
    );
  }

  Future<Either<Failure, ClinicOffersResponse>> getClinicOffers({
    required int centerId,
  }) {
    return callApiWithErrorParser(
      dio.get('${ApiEndpoints.centers}/$centerId/offers'),
      ClinicOffersResponse.fromJson,
    );
  }

  Future<Either<Failure, ClinicPortfolioResponse>> getClinicPortfolio({
    required int centerId,
  }) {
    return callApiWithErrorParser(
      dio.get('${ApiEndpoints.centers}/$centerId/portfolio'),
      ClinicPortfolioResponse.fromJson,
    );
  }

  Future<Either<Failure, ClinicServicesResponse>> getClinicServices({
    required int centerId,
    ClinicServiceFilters filters = const ClinicServiceFilters(),
  }) {
    return callApiWithErrorParser(
      dio.get(
        '${ApiEndpoints.centers}/$centerId/services',
        queryParameters: filters.toQueryParameters(),
      ),
      ClinicServicesResponse.fromJson,
    );
  }
}
