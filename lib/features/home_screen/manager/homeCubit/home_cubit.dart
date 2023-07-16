import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repo/home_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.homeRepo, this.user) : super(HomeState.initial());

  final HomeRepo homeRepo;
  final FirebaseAuth user;

  User? getCurrentUser() {
    return user.currentUser;
  }

  Future signOut() async {
    await user.signOut();
  }

  void getDeviceToken() {
    homeRepo.getDeviceToken();
  }

  void onTokenRefresh() {
    homeRepo.onTokenRefresh();
  }
}
