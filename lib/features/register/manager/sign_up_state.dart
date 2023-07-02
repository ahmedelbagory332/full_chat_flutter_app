import '../../../core/utils/failures.dart';

enum SignUpStatus { initial, loading, registerDevice, success, error }

class SignUpState {
  final SignUpStatus status;
  final Failure failure;
  final String name;
  final String email;
  final String password;
  bool get isFormValid => email.isEmpty || name.isEmpty || password.isEmpty;

  const SignUpState({
    required this.status,
    required this.failure,
    required this.name,
    required this.email,
    required this.password,
  });

  factory SignUpState.initial() {
    return const SignUpState(
      status: SignUpStatus.initial,
      failure: Failure(""),
      name: "",
      email: "",
      password: "",
    );
  }

  SignUpState copyWith({
    SignUpStatus? status,
    Failure? failure,
    String? name,
    String? email,
    String? password,
  }) {
    return SignUpState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
