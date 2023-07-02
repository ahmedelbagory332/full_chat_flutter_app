import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:full_chat_application/features/splash_screen/manager/splash_screen_state.dart';

class SplashScreenCubit extends Cubit<SplashScreenState> {
  SplashScreenCubit(this.user) : super(SplashScreenState.initial());
  final FirebaseAuth user;

  void initRoute() {
    Timer(const Duration(seconds: 2), () {
      if (user.currentUser != null) {
        emit(state.copyWith(status: SplashScreenStatus.home));
      } else {
        emit(state.copyWith(status: SplashScreenStatus.auth));
      }
    });
  }
}
