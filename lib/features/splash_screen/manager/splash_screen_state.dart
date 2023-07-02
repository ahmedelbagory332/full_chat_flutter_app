import '../../../core/utils/failures.dart';

enum SplashScreenStatus {
  initial,
  home,
  auth,
}

class SplashScreenState {
  final SplashScreenStatus status;
  final Failure failure;

  const SplashScreenState({
    required this.status,
    required this.failure,
  });

  factory SplashScreenState.initial() {
    return const SplashScreenState(
      status: SplashScreenStatus.initial,
      failure: Failure(""),
    );
  }

  SplashScreenState copyWith({
    SplashScreenStatus? status,
    Failure? failure,
  }) {
    return SplashScreenState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
