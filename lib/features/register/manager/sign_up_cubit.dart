import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:full_chat_application/features/register/manager/sign_up_state.dart';

import '../../../core/utils/failures.dart';
import '../data/repo/sign_up_repo.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this.signUpRepo, this.user) : super(SignUpState.initial());

  final SignUpRepo signUpRepo;
  final FirebaseAuth user;

  User? getCurrentUser() {
    return user.currentUser;
  }

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: SignUpStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: SignUpStatus.initial));
  }

  void nameChanged(String value) {
    emit(state.copyWith(name: value, status: SignUpStatus.initial));
  }

  void signUp() async {
    if (state.isFormValid) {
      emit(state.copyWith(
          status: SignUpStatus.error,
          failure: const Failure("please check your info.")));
    } else {
      emit(state.copyWith(status: SignUpStatus.loading));

      var result = await signUpRepo.signUp(
          name: state.name, email: state.email, password: state.password);
      result.fold((failure) {
        emit(state.copyWith(failure: failure, status: SignUpStatus.error));
      }, (success) async {
        emit(state.copyWith(status: SignUpStatus.registerDevice));
      });
    }
  }

  void registerDevice() async {
    var token = await signUpRepo.getDeviceToken();
    debugPrint("bego : $token");
    var result = await signUpRepo.registerDevice(state.email, token.toString());
    result.fold((failure) {
      debugPrint("bego registerDevice: ${failure.errMessage}");
      emit(state.copyWith(failure: failure, status: SignUpStatus.error));
    }, (success) {
      emit(state.copyWith(status: SignUpStatus.success));
    });
  }
}
