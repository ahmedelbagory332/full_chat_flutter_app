import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/repo/home_repo_impl.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this.homeRepo, this.user) : super(UsersState.initial());

  final HomeRepoImpl homeRepo;
  final FirebaseAuth user;
  late StreamSubscription _usersSubscription;

  User? getCurrentUser() {
    return user.currentUser;
  }

  void getUsers() {
    emit(state.copyWith(status: UsersStatus.loading));
    _usersSubscription = homeRepo.getAllUsers().listen((either) {
      either.fold(
        (error) =>
            emit(state.copyWith(failure: error, status: UsersStatus.error)),
        (users) => emit(
            state.copyWith(status: UsersStatus.success, users: users.docs)),
      );
    });
  }

  @override
  Future<void> close() {
    _usersSubscription.cancel();
    return super.close();
  }

  Future<void> usersClickListener(String userId) async {
    emit(state.copyWith(status: UsersStatus.loading));
    var user = await homeRepo.usersClickListener(userId);
    user.fold((failure) {
      emit(state.copyWith(failure: failure, status: UsersStatus.error));
    }, (peerUserData) async {
      emit(state.copyWith(
          status: UsersStatus.navigateToChat, peerUserData: peerUserData));
    });
  }
}
