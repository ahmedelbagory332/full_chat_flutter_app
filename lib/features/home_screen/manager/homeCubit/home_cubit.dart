import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:full_chat_application/features/home_screen/data/repo/home_repo_impl.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.homeRepo, this.user) : super(HomeState.initial());

  final HomeRepoImpl homeRepo;
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
