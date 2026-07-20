import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/features/home/cubit/home_state.dart';
import 'package:beauty_center_app/features/home/models/home_response.dart';
import 'package:beauty_center_app/features/home/repository/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._homeRepository) : super(const HomeState());

  final HomeRepository _homeRepository;

  Future<void> loadHome() async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        clearMessage: true,
      ),
    );

    final Either<Failure, HomeResponse> homeResult = await _homeRepository
        .getHome();
    if (isClosed) {
      return;
    }

    homeResult.fold(
      (Failure failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          message: failure.message,
        ),
      ),
      (HomeResponse response) => emit(
        state.copyWith(
          status: HomeStatus.success,
          data: response.data,
        ),
      ),
    );
  }
}
