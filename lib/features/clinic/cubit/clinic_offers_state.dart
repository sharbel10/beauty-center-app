import 'package:beauty_center_app/features/clinic/models/clinics_offers_response.dart';
import 'package:equatable/equatable.dart';

abstract class ClinicOffersState extends Equatable {
  const ClinicOffersState();
  @override
  List<Object?> get props => [];
}

class ClinicOffersInitial extends ClinicOffersState {}

class ClinicOffersLoading extends ClinicOffersState {}

class ClinicOffersSuccess extends ClinicOffersState {
  final List<ClinicOffer> offers;
  const ClinicOffersSuccess(this.offers);
  @override
  List<Object?> get props => [offers];
}

class ClinicOffersFailure extends ClinicOffersState {
  final String errorMessage;
  const ClinicOffersFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}
