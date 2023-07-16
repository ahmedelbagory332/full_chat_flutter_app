import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:full_chat_application/features/logIn/manager/sign_in_state.dart';

import '../../../core/utils/failures.dart';
import '../data/repo/sign_in_repo.dart';

class SigInCubit extends Cubit<SignInState> {
  SigInCubit(this.signInRepo, this.user) : super(SignInState.initial());

  final SignInRepo signInRepo;
  final FirebaseAuth user;

  User? getCurrentUser() {
    return user.currentUser;
  }

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: SignInStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: SignInStatus.initial));
  }

  void signIn() async {
    if (state.isFormValid) {
      emit(state.copyWith(
          status: SignInStatus.error,
          failure: const Failure("please check your info.")));
    } else {
      emit(state.copyWith(
          status: SignInStatus.loading, failure: const Failure("")));

      var result =
          await signInRepo.signIn(email: state.email, password: state.password);

      result.fold((failure) {
        emit(state.copyWith(failure: failure, status: SignInStatus.error));
      }, (success) async {
        emit(state.copyWith(
            failure: const Failure(""), status: SignInStatus.success));
      });
    }
  }
}
