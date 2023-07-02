import '../../../core/utils/failures.dart';

enum SignInStatus { initial, loading, success, error }

class SignInState {
  final SignInStatus status;
  final Failure failure;
  final String email;
  final String password;
  bool get isFormValid => email.isEmpty || password.isEmpty;

  const SignInState({
    required this.status,
    required this.failure,
    required this.email,
    required this.password,
  });

  factory SignInState.initial() {
    return const SignInState(
      status: SignInStatus.initial,
      failure: Failure(""),
      email: "",
      password: "",
    );
  }

  SignInState copyWith({
    SignInStatus? status,
    Failure? failure,
    String? email,
    String? password,
  }) {
    return SignInState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
