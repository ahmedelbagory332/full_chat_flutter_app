import '../../../../core/utils/failures.dart';

enum HomeStatus { initial, loading, success, navigateToChat, error }

class HomeState {
  final HomeStatus status;
  final Failure failure;

  const HomeState({
    required this.status,
    required this.failure,
  });

  factory HomeState.initial() {
    return const HomeState(status: HomeStatus.initial, failure: Failure(""));
  }

  HomeState copyWith({HomeStatus? status, Failure? failure}) {
    return HomeState(
        status: status ?? this.status, failure: failure ?? this.failure);
  }
}
