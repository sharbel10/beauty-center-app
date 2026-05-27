import 'package:beauty_center_app/features/clinic/models/clinics_portfolio_response.dart';
import 'package:equatable/equatable.dart';

abstract class ClinicPortfolioState extends Equatable {
  const ClinicPortfolioState();
  @override
  List<Object?> get props => [];
}

class ClinicPortfolioInitial extends ClinicPortfolioState {}

class ClinicPortfolioLoading extends ClinicPortfolioState {}

class ClinicPortfolioSuccess extends ClinicPortfolioState {
  final List<ClinicPortfolioItem> portfolio;
  const ClinicPortfolioSuccess(this.portfolio);
  @override
  List<Object?> get props => [portfolio];
}

class ClinicPortfolioFailure extends ClinicPortfolioState {
  final String errorMessage;
  const ClinicPortfolioFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}
