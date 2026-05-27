import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/features/home/cubit/home_state.dart';
import 'package:beauty_center_app/features/home/repository/home_repository.dart';
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

    final result = await _homeRepository.getHome();
    result.fold(
      (Failure failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          message: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          status: HomeStatus.success,
          data: response.data,
        ),
      ),
    );
  }
}
