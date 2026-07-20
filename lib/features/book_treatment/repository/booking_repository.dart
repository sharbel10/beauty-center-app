import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/book_treatment/models/available_slots_response.dart';
import 'package:beauty_center_app/features/bookings/models/appointments_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_employees_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class BookingRepository extends BaseRepository {
  BookingRepository(super.dioClient);

  Future<Either<Failure, ClinicServicesResponse>> getClinicServices({
    required int centerId,
  }) {
    return callApiWithErrorParser(
      dio.get('${ApiEndpoints.centers}/$centerId/services'),
      ClinicServicesResponse.fromJson,
    );
  }

  Future<Either<Failure, ClinicEmployeesResponse>> getClinicEmployees({
    required int centerId,
    int? serviceId,
  }) {
    final Map<String, dynamic> queryParameters = <String, dynamic>{};
    if (serviceId != null) {
      queryParameters['service_id'] = serviceId;
    }

    return callApiWithErrorParser(
      dio.get(
        '${ApiEndpoints.centers}/$centerId/employees',
        queryParameters: queryParameters,
      ),
      ClinicEmployeesResponse.fromJson,
    );
  }

  Future<Either<Failure, AvailableSlotsResponse>> getAvailableSlots({
    required int centerId,
    required int serviceId,
    required DateTime date,
    int? employeeId,
  }) {
    final Map<String, dynamic> queryParameters = <String, dynamic>{
      'service_id': serviceId,
      'date': _formatApiDate(date),
    };
    if (employeeId != null) {
      queryParameters['employee_id'] = employeeId;
    }

    return callApiWithErrorParser(
      dio.get(
        '${ApiEndpoints.centers}/$centerId/available-slots',
        queryParameters: queryParameters,
      ),
      AvailableSlotsResponse.fromJson,
    );
  }

  Future<Either<Failure, AppointmentsResponse>> getAppointments({
    String? scope,
  }) {
    final Map<String, dynamic> queryParameters = <String, dynamic>{};
    if (scope != null) {
      queryParameters['scope'] = scope;
    }

    return callApiWithErrorParser(
      dio.get(ApiEndpoints.appointments, queryParameters: queryParameters),
      AppointmentsResponse.fromJson,
    );
  }

  Future<Either<Failure, AppointmentResponse>> getAppointment({
    required int appointmentId,
  }) {
    return callApiWithErrorParser(
      dio.get('${ApiEndpoints.appointments}/$appointmentId'),
      AppointmentResponse.fromJson,
    );
  }

  Future<Either<Failure, AppointmentResponse>> createAppointment({
    required int centerId,
    required int serviceId,
    required String startsAt,
    int? employeeId,
    String? customerNotes,
  }) {
    final Map<String, dynamic> data = <String, dynamic>{
      'center_id': centerId,
      'service_id': serviceId,
      'starts_at': startsAt,
    };
    if (employeeId != null) {
      data['employee_id'] = employeeId;
    }
    if (customerNotes != null && customerNotes.trim().isNotEmpty) {
      data['customer_notes'] = customerNotes.trim();
    }

    return callApiWithErrorParser(
      dio.post(ApiEndpoints.appointments, data: data),
      AppointmentResponse.fromJson,
    );
  }

  Future<Either<Failure, AppointmentResponse>> rescheduleAppointment({
    required int appointmentId,
    required String startsAt,
    int? employeeId,
  }) {
    final Map<String, dynamic> data = <String, dynamic>{'starts_at': startsAt};
    if (employeeId != null) {
      data['employee_id'] = employeeId;
    }

    return callApiWithErrorParser(
      dio.patch(
        '${ApiEndpoints.appointments}/$appointmentId/reschedule',
        data: data,
      ),
      AppointmentResponse.fromJson,
    );
  }

  Future<Either<Failure, AppointmentResponse>> cancelAppointment({
    required int appointmentId,
    String? reason,
  }) {
    return callApiWithErrorParser(
      dio.patch(
        '${ApiEndpoints.appointments}/$appointmentId/cancel',
        data: <String, dynamic>{
          'cancellation_reason': reason?.trim().isNotEmpty == true
              ? reason!.trim()
              : 'Cancelled by customer.',
        },
      ),
      AppointmentResponse.fromJson,
    );
  }
}

String _formatApiDate(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
